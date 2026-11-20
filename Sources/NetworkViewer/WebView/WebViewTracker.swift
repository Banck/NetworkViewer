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
    /// `load(_:mimeType:…)`) to `ignore(_:)`.
    final class WebViewTracker {

        /// Off by default; turning it on does not change web view behaviour.
        public static var isEnabled = false

        fileprivate struct Record {
            let id: String
            var url: String
            /// `nil` when WebKit did not tell the method (e.g. after a redirect); never guessed.
            var method: String?
            var requestHeaders: [String: String]
            var requestBody: Data?
            var response: Response?
            var error: CustomError?
            var startAt: TimeInterval
            var endAt: TimeInterval?
            var redirectURL: String?
            var isFromIFrame: Bool

            var operation: Operation {
                Operation(
                    id: id,
                    request: Request(url: url, method: method ?? "", headers: requestHeaders, body: requestBody),
                    response: response,
                    responseData: Data(),
                    error: error,
                    startAt: startAt,
                    endAt: endAt,
                    isFromWebView: true,
                    isFromIFrame: isFromIFrame,
                    redirectURL: redirectURL
                )
            }
        }

        fileprivate struct Navigation {
            /// Retained so its `ObjectIdentifier` is not reused while the navigation is tracked.
            let object: AnyObject
            /// `nil` — the navigation is not logged (ignored or not http(s)).
            var recordID: String?
        }

        private let now: () -> Date
        private let onChange: (Operation) -> Void

        private var navigations: [ObjectIdentifier: Navigation] = [:]
        private var ignored: [ObjectIdentifier: AnyObject] = [:]
        private var records: [String: Record] = [:]
        /// Main frame request allowed by the last navigation action, not yet started.
        private var pendingRequest: URLRequest?
        /// The last started and not finished navigation: main frame responses belong to it.
        private var currentKey: ObjectIdentifier?

        public convenience init() {
            self.init(now: Date.init, onChange: NetworkViewer.updateOperation)
        }

        init(now: @escaping () -> Date, onChange: @escaping (Operation) -> Void) {
            self.now = now
            self.onChange = onChange
        }

        // MARK: - WebKit events

        public func ignore(_ navigation: WKNavigation?) {
            guard Self.isEnabled else { return }
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
            guard Self.isEnabled else { return }
            start(navigation, url: webView.url)
        }

        public func didReceiveServerRedirect(_ navigation: WKNavigation?, in webView: WKWebView) {
            guard Self.isEnabled else { return }
            redirect(navigation, url: webView.url)
        }

        public func didReceive(_ navigationResponse: WKNavigationResponse) {
            guard Self.isEnabled else { return }
            receive(navigationResponse.response, isMainFrame: navigationResponse.isForMainFrame)
        }

        public func didFinish(_ navigation: WKNavigation?) {
            guard Self.isEnabled else { return }
            finish(navigation)
        }

        /// Both provisional and committed navigation failures.
        public func didFail(_ navigation: WKNavigation?, error: Error) {
            guard Self.isEnabled else { return }
            fail(navigation, error: error)
        }

        // MARK: - Tracking

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
            guard let navigation else { return }
            ignored[ObjectIdentifier(navigation)] = navigation
        }

        func decide(request: URLRequest, isMainFrame: Bool, isAllowed: Bool) {
            guard isMainFrame else { return }
            pendingRequest = isAllowed && Self.isHTTP(request.url) ? request : nil
        }

        func start(_ navigation: AnyObject?, url: URL?) {
            let time = now()
            let request = takePendingRequest(for: url)
            guard let navigation else { return }
            let key = ObjectIdentifier(navigation)
            currentKey = key

            guard ignored[key] == nil, Self.isHTTP(url), let url else {
                navigations[key] = Navigation(object: navigation, recordID: nil)
                return
            }
            navigations[key] = Navigation(object: navigation, recordID: startRecord(url: url, request: request, at: time))
        }

        func redirect(_ navigation: AnyObject?, url: URL?) {
            let time = now()
            let request = takePendingRequest(for: url)
            guard let key = resolve(navigation), let recordID = navigations[key]?.recordID else { return }

            update(recordID) {
                $0.redirectURL = url?.absoluteString
                $0.endAt = time.timeIntervalSince1970
            }
            records[recordID] = nil
            let nextID = Self.isHTTP(url) ? url.map { startRecord(url: $0, request: request, at: time) } : nil
            navigations[key]?.recordID = nextID
        }

        func receive(_ response: URLResponse, isMainFrame: Bool) {
            let time = now().timeIntervalSince1970
            guard let response = response as? HTTPURLResponse, Self.isHTTP(response.url), let url = response.url else { return }
            let httpResponse = Response(statusCode: response.statusCode, headers: Self.headers(response))

            if isMainFrame {
                guard let key = currentKey, let recordID = navigations[key]?.recordID else { return }
                update(recordID) { $0.response = httpResponse }
            } else {
                let record = Record(
                    id: UUID().uuidString,
                    url: url.absoluteString,
                    method: nil,
                    requestHeaders: [:],
                    requestBody: nil,
                    response: httpResponse,
                    error: nil,
                    startAt: time,
                    endAt: time,
                    redirectURL: nil,
                    isFromIFrame: true
                )
                onChange(record.operation)
            }
        }

        func finish(_ navigation: AnyObject?) {
            let time = now()
            guard let key = resolve(navigation) else { return }
            complete(key) { $0.endAt = time.timeIntervalSince1970 }
        }

        func fail(_ navigation: AnyObject?, error: Error) {
            let time = now()
            guard let key = resolve(navigation) else { return }
            let nsError = error as NSError
            complete(key) {
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

    /// `nil` navigation is applied only when there is exactly one candidate.
    func resolve(_ navigation: AnyObject?) -> ObjectIdentifier? {
        if let navigation {
            return ObjectIdentifier(navigation)
        }
        return navigations.count == 1 ? navigations.keys.first : nil
    }

    func startRecord(url: URL, request: URLRequest?, at time: Date) -> String {
        let record = Record(
            id: UUID().uuidString,
            url: url.absoluteString,
            method: request?.httpMethod,
            requestHeaders: request?.allHTTPHeaderFields ?? [:],
            requestBody: request?.httpBody,
            response: nil,
            error: nil,
            startAt: time.timeIntervalSince1970,
            endAt: nil,
            redirectURL: nil,
            isFromIFrame: false
        )
        records[record.id] = record
        onChange(record.operation)
        return record.id
    }

    func update(_ recordID: String, _ change: (inout Record) -> Void) {
        guard var record = records[recordID] else { return }
        change(&record)
        records[recordID] = record
        onChange(record.operation)
    }

    /// Terminal event: the record is final, the navigation object is released.
    func complete(_ key: ObjectIdentifier, _ change: (inout Record) -> Void) {
        if let recordID = navigations[key]?.recordID {
            update(recordID, change)
            records[recordID] = nil
        }
        navigations[key] = nil
        ignored[key] = nil
        if currentKey == key {
            currentKey = nil
        }
    }
}
