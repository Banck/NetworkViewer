//
//  WebViewTracker.swift
//

import Foundation
import WebKit

public extension NetworkViewer {

    /// Logs the navigations of one web view as operations, from its `WKNavigationDelegate` events.
    /// One instance per web view, main thread only. Does nothing while `isEnabled` is `false`.
    ///
    /// Call it from the delegate before handing the event on:
    /// `decidePolicyFor navigationAction` — wrap the handler with `decisionHandler(for:_:)`;
    /// `didStartProvisionalNavigation`, `didReceiveServerRedirectForProvisionalNavigation`,
    /// `decidePolicyFor navigationResponse`, `didFinish`, `didFailProvisionalNavigation`, `didFail`.
    /// Pass navigations of content that is not loaded from the network (`loadHTMLString`, `loadFileURL`,
    /// `load(_:mimeType:…)`) to `ignore(_:)`. Events WebKit reports without a `WKNavigation` object are not logged.
    final class WebViewTracker {

        /// Off by default; turning it on does not change web view behaviour.
        /// Set it once, before web views start loading: navigations in progress when it changes are not completed.
        public static var isEnabled = false

        fileprivate struct Navigation {
            /// Retained so its `ObjectIdentifier` is not reused while the navigation is tracked.
            let object: AnyObject
            /// `nil` — the navigation is not logged (ignored or not http(s)).
            var operation: Operation?
        }

        private let now: () -> Date
        /// The operation and whether it is new (added) or a later state of an added one (updated).
        private let onChange: (Operation, _ isNew: Bool) -> Void

        private var navigations: [ObjectIdentifier: Navigation] = [:]
        /// Main frame request allowed by the last navigation action, not yet started.
        private var pendingRequest: URLRequest?
        /// The last started and not finished navigation: main frame responses belong to it.
        private var currentKey: ObjectIdentifier?

        public convenience init() {
            self.init(now: Date.init) { operation, isNew in
                // Updates of operations deleted meanwhile are dropped, so cleared rows do not come back.
                isNew ? NetworkViewer.addOperation(operation) : NetworkViewer.updateOperation(operation)
            }
        }

        init(now: @escaping () -> Date, onChange: @escaping (Operation, _ isNew: Bool) -> Void) {
            self.now = now
            self.onChange = onChange
        }

        // MARK: - WebKit events

        public func ignore(_ navigation: WKNavigation?) {
            ignoreNavigation(navigation)
        }

        /// Returns a handler that reports the decision and then calls `handler` exactly once with the same policy.
        public func decisionHandler(
            for navigationAction: WKNavigationAction,
            _ handler: @escaping (WKNavigationActionPolicy) -> Void
        ) -> (WKNavigationActionPolicy) -> Void {
            decisionHandler(
                handler,
                request: navigationAction.request,
                isMainFrame: navigationAction.targetFrame?.isMainFrame == true
            )
        }

        public func didStartProvisionalNavigation(_ navigation: WKNavigation?, in webView: WKWebView) {
            start(navigation, url: webView.url)
        }

        public func didReceiveServerRedirect(_ navigation: WKNavigation?, in webView: WKWebView) {
            redirect(navigation, url: webView.url)
        }

        public func didReceive(_ navigationResponse: WKNavigationResponse) {
            receive(navigationResponse.response, isMainFrame: navigationResponse.isForMainFrame)
        }

        public func didFinish(_ navigation: WKNavigation?) {
            finish(navigation)
        }

        /// Both provisional and committed navigation failures.
        public func didFail(_ navigation: WKNavigation?, error: Error) {
            fail(navigation, error: error)
        }

        // MARK: - Tracking
        // Events without a navigation object are ignored: which navigation they belong to is unknown.

        func decisionHandler(
            _ handler: @escaping (WKNavigationActionPolicy) -> Void,
            request: URLRequest,
            isMainFrame: Bool
        ) -> (WKNavigationActionPolicy) -> Void {
            guard Self.isEnabled else { return handler }
            return { [weak self] policy in
                self?.decide(request: request, isMainFrame: isMainFrame, isAllowed: policy == .allow)
                handler(policy)
            }
        }

        func ignoreNavigation(_ navigation: AnyObject?) {
            guard Self.isEnabled, let navigation else { return }
            navigations[ObjectIdentifier(navigation)] = Navigation(object: navigation, operation: nil)
        }

        func decide(request: URLRequest, isMainFrame: Bool, isAllowed: Bool) {
            guard isMainFrame else { return }
            pendingRequest = isAllowed && Self.isHTTP(request.url) ? request : nil
        }

        func start(_ navigation: AnyObject?, url: URL?) {
            guard Self.isEnabled else { return }
            let time = now()
            let request = takePendingRequest(for: url)
            guard let navigation else { return }
            let key = ObjectIdentifier(navigation)
            currentKey = key
            // Already known: an ignored navigation.
            guard navigations[key] == nil else { return }

            let operation = Self.isHTTP(url) ? url.map { newOperation(url: $0, request: request, at: time) } : nil
            navigations[key] = Navigation(object: navigation, operation: operation)
        }

        func redirect(_ navigation: AnyObject?, url: URL?) {
            guard Self.isEnabled else { return }
            let time = now()
            let request = takePendingRequest(for: url)
            guard let navigation else { return }
            let key = ObjectIdentifier(navigation)
            guard navigations[key]?.operation != nil else { return }

            update(key) {
                $0.redirectURL = url?.absoluteString
                $0.endAt = time.timeIntervalSince1970
            }
            navigations[key]?.operation = Self.isHTTP(url) ? url.map { newOperation(url: $0, request: request, at: time) } : nil
        }

        func receive(_ response: URLResponse, isMainFrame: Bool) {
            guard Self.isEnabled else { return }
            let time = now().timeIntervalSince1970
            guard let response = response as? HTTPURLResponse, Self.isHTTP(response.url), let url = response.url else { return }
            let httpResponse = Response(statusCode: response.statusCode, headers: Self.headers(response))

            if isMainFrame {
                guard let key = currentKey else { return }
                update(key) { $0.response = httpResponse }
            } else {
                onChange(Operation(
                    id: UUID().uuidString,
                    request: Request(url: url.absoluteString, method: "", headers: [:], body: nil),
                    response: httpResponse,
                    responseData: Data(),
                    error: nil,
                    startAt: time,
                    endAt: time,
                    isFromWebView: true,
                    isFromIFrame: true
                ), true)
            }
        }

        func finish(_ navigation: AnyObject?) {
            guard Self.isEnabled, let navigation else { return }
            let time = now()
            complete(ObjectIdentifier(navigation)) { $0.endAt = time.timeIntervalSince1970 }
        }

        func fail(_ navigation: AnyObject?, error: Error) {
            guard Self.isEnabled, let navigation else { return }
            let time = now()
            let nsError = error as NSError
            complete(ObjectIdentifier(navigation)) {
                $0.error = CustomError(code: nsError.code, message: "\(nsError.localizedDescription) (\(nsError.domain))")
                $0.endAt = time.timeIntervalSince1970
            }
        }
    }
}

private extension NetworkViewer.WebViewTracker {

    static func isHTTP(_ url: URL?) -> Bool {
        guard let scheme = url?.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }

    static func headers(_ response: HTTPURLResponse) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            headers["\(key)"] = "\(value)"
        }
        return headers
    }

    /// The pending action describes this request only when it targets the same URL.
    func takePendingRequest(for url: URL?) -> URLRequest? {
        defer { pendingRequest = nil }
        guard let pendingRequest, let url, pendingRequest.url?.absoluteString == url.absoluteString else { return nil }
        return pendingRequest
    }

    func newOperation(url: URL, request: URLRequest?, at time: Date) -> NetworkViewer.Operation {
        let operation = NetworkViewer.Operation(
            id: UUID().uuidString,
            request: NetworkViewer.Request(
                url: url.absoluteString,
                method: request?.httpMethod ?? "",
                headers: request?.allHTTPHeaderFields ?? [:],
                body: request?.httpBody
            ),
            response: nil,
            responseData: Data(),
            error: nil,
            startAt: time.timeIntervalSince1970,
            endAt: nil,
            isFromWebView: true
        )
        onChange(operation, true)
        return operation
    }

    func update(_ key: ObjectIdentifier, _ change: (inout NetworkViewer.Operation) -> Void) {
        guard var operation = navigations[key]?.operation else { return }
        change(&operation)
        navigations[key]?.operation = operation
        onChange(operation, false)
    }

    /// Terminal event: the operation is final, the navigation object is released.
    func complete(_ key: ObjectIdentifier, _ change: (inout NetworkViewer.Operation) -> Void) {
        update(key, change)
        navigations[key] = nil
        if currentKey == key {
            currentKey = nil
        }
    }
}
