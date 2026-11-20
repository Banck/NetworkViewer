import WebKit
import XCTest
@testable import NetworkViewer

final class WebViewTrackerTests: XCTestCase {

    private var operations: [String: NetworkViewer.Operation] = [:]
    private var order: [String] = []
    private var time: TimeInterval = 0
    private var tracker: NetworkViewer.WebViewTracker!

    override func setUp() {
        super.setUp()
        operations = [:]
        order = []
        time = 0
        tracker = NetworkViewer.WebViewTracker(
            now: { [unowned self] in
                time += 1
                return Date(timeIntervalSince1970: time)
            },
            onChange: { [unowned self] operation in
                if operations[operation.id] == nil {
                    order.append(operation.id)
                }
                operations[operation.id] = operation
            }
        )
    }

    override func tearDown() {
        NetworkViewer.WebViewTracker.isEnabled = false
        NetworkViewer.deleteAllOperations()
        super.tearDown()
    }

    private var all: [NetworkViewer.Operation] {
        order.compactMap { operations[$0] }
    }

    // MARK: - Main frame

    func testFullMainFrameNavigation() throws {
        let navigation = NSObject()
        var request = URLRequest(url: URL(string: "https://pay.test/start")!)
        request.httpMethod = "POST"
        request.httpBody = Data("a=1".utf8)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")

        tracker.decide(request: request, isMainFrame: true, isAllowed: true)
        tracker.start(navigation, url: URL(string: "https://pay.test/start"))
        tracker.receive(httpResponse("https://pay.test/start", status: 200, headers: ["Server": "x"]), isMainFrame: true)
        tracker.finish(navigation)

        XCTAssertEqual(all.count, 1)
        let operation = try XCTUnwrap(all.first)
        XCTAssertEqual(operation.request.url, "https://pay.test/start")
        XCTAssertEqual(operation.request.method, "POST")
        XCTAssertEqual(operation.request.body, Data("a=1".utf8))
        XCTAssertEqual(operation.request.headers["Content-Type"], "text/plain")
        XCTAssertEqual(operation.response?.statusCode, 200)
        XCTAssertEqual(operation.response?.headers["Server"], "x")
        XCTAssertEqual(operation.startAt, 1)
        XCTAssertEqual(operation.endAt, 3)
        XCTAssertNil(operation.error)
        XCTAssertNil(operation.redirectURL)
        XCTAssertTrue(operation.isFromWebView)
        XCTAssertFalse(operation.isFromIFrame)
        XCTAssertTrue(operation.responseData.isEmpty)
    }

    func testCancelledActionDoesNotGiveMethodToNextNavigation() {
        var request = URLRequest(url: URL(string: "https://a.test/")!)
        request.httpMethod = "POST"
        tracker.decide(request: request, isMainFrame: true, isAllowed: false)

        tracker.start(NSObject(), url: URL(string: "https://a.test/"))

        XCTAssertEqual(all.map(\.request.method), [""])
    }

    func testPendingActionForAnotherURLIsNotUsed() {
        var request = URLRequest(url: URL(string: "https://a.test/form")!)
        request.httpMethod = "POST"
        tracker.decide(request: request, isMainFrame: true, isAllowed: true)

        tracker.start(NSObject(), url: URL(string: "https://a.test/other"))

        XCTAssertEqual(all.map(\.request.method), [""])
        XCTAssertEqual(all.map(\.request.url), ["https://a.test/other"])
    }

    func testProvisionalFailureIsErrorWithDomain() throws {
        let navigation = NSObject()
        tracker.start(navigation, url: URL(string: "https://a.test/"))

        tracker.fail(navigation, error: NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: [NSLocalizedDescriptionKey: "Offline"]
        ))

        let operation = try XCTUnwrap(all.first)
        XCTAssertEqual(operation.error?.code, -1009)
        XCTAssertEqual(operation.error?.message, "Offline (NSURLErrorDomain)")
        XCTAssertNil(operation.response)
        XCTAssertEqual(operation.endAt, 2)
    }

    func testFailureAfterResponseKeepsStatus() throws {
        let navigation = NSObject()
        tracker.start(navigation, url: URL(string: "https://a.test/"))
        tracker.receive(httpResponse("https://a.test/", status: 200), isMainFrame: true)

        tracker.fail(navigation, error: NSError(domain: "WebKitErrorDomain", code: 102))

        let operation = try XCTUnwrap(all.first)
        XCTAssertEqual(operation.response?.statusCode, 200)
        XCTAssertEqual(operation.error?.code, 102)
    }

    func testFinishWithoutResponseCompletesOperationWithoutStatus() throws {
        let navigation = NSObject()
        tracker.start(navigation, url: URL(string: "https://a.test/back"))

        tracker.finish(navigation)

        let operation = try XCTUnwrap(all.first)
        XCTAssertNil(operation.response)
        XCTAssertNil(operation.error)
        XCTAssertNotNil(operation.endAt)
    }

    // MARK: - Redirects

    func testRedirectClosesStepAndTakesTargetMethodFromAction() {
        let navigation = NSObject()
        var post = URLRequest(url: URL(string: "https://a.test/pay")!)
        post.httpMethod = "POST"
        tracker.decide(request: post, isMainFrame: true, isAllowed: true)
        tracker.start(navigation, url: URL(string: "https://a.test/pay"))
        var redirected = URLRequest(url: URL(string: "https://b.test/3ds")!)
        redirected.httpMethod = "POST"
        tracker.decide(request: redirected, isMainFrame: true, isAllowed: true)

        tracker.redirect(navigation, url: URL(string: "https://b.test/3ds"))
        tracker.receive(httpResponse("https://b.test/3ds", status: 200), isMainFrame: true)
        tracker.finish(navigation)

        XCTAssertEqual(all.map(\.request.url), ["https://a.test/pay", "https://b.test/3ds"])
        XCTAssertEqual(all.map(\.request.method), ["POST", "POST"])
        XCTAssertEqual(all[0].redirectURL, "https://b.test/3ds")
        XCTAssertNotNil(all[0].endAt)
        XCTAssertNil(all[0].response)
        XCTAssertEqual(all[1].response?.statusCode, 200)
        XCTAssertNotNil(all[1].endAt)
    }

    func testRedirectWithoutActionHasUnknownMethod() {
        let navigation = NSObject()
        var post = URLRequest(url: URL(string: "https://a.test/pay")!)
        post.httpMethod = "POST"
        tracker.decide(request: post, isMainFrame: true, isAllowed: true)
        tracker.start(navigation, url: URL(string: "https://a.test/pay"))

        tracker.redirect(navigation, url: URL(string: "https://b.test/next"))

        XCTAssertEqual(all.map(\.request.method), ["POST", ""])
    }

    // MARK: - Subframes

    func testIFrameResponseIsSeparateOperationWithoutDuration() throws {
        let navigation = NSObject()
        tracker.start(navigation, url: URL(string: "https://a.test/"))
        tracker.decide(request: URLRequest(url: URL(string: "https://captcha.test/frame")!), isMainFrame: false, isAllowed: true)

        tracker.receive(httpResponse("https://captcha.test/frame", status: 403), isMainFrame: false)
        tracker.finish(navigation)

        XCTAssertEqual(all.count, 2)
        let iframe = all[1]
        XCTAssertTrue(iframe.isFromIFrame)
        XCTAssertTrue(iframe.isFromWebView)
        XCTAssertEqual(iframe.request.url, "https://captcha.test/frame")
        XCTAssertEqual(iframe.request.method, "")
        XCTAssertEqual(iframe.response?.statusCode, 403)
        XCTAssertEqual(iframe.startAt, iframe.endAt)
        XCTAssertNil(all[0].response)
    }

    // MARK: - What is not logged

    func testIgnoredNavigationIsNotLoggedButItsIFramesAre() {
        let navigation = NSObject()
        tracker.ignoreNavigation(navigation)

        tracker.start(navigation, url: URL(string: "https://captcha-base.test/"))
        tracker.receive(httpResponse("https://captcha-base.test/", status: 200), isMainFrame: true)
        tracker.receive(httpResponse("https://captcha.test/frame", status: 200), isMainFrame: false)
        tracker.finish(navigation)

        XCTAssertEqual(all.map(\.request.url), ["https://captcha.test/frame"])
    }

    func testNavigationAfterIgnoredOneFinishedIsLogged() {
        let ignored = NSObject()
        tracker.ignoreNavigation(ignored)
        tracker.start(ignored, url: URL(string: "https://base.test/"))
        tracker.finish(ignored)

        tracker.start(NSObject(), url: URL(string: "https://a.test/"))

        XCTAssertEqual(all.map(\.request.url), ["https://a.test/"])
    }

    func testNonHTTPNavigationsAreNotLogged() {
        for url in ["about:blank", "data:text/html,hi", "file:///tmp/a.html", "olimp://deeplink"] {
            let navigation = NSObject()
            tracker.start(navigation, url: URL(string: url))
            tracker.finish(navigation)
        }
        tracker.receive(httpResponse("about:blank", status: 200), isMainFrame: false)

        XCTAssertTrue(all.isEmpty)
    }

    // MARK: - Overlapping navigations

    func testNewNavigationBeforeFirstFinishes() {
        let first = NSObject()
        let second = NSObject()
        tracker.start(first, url: URL(string: "https://a.test/1"))
        tracker.start(second, url: URL(string: "https://a.test/2"))

        tracker.fail(first, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled))
        tracker.receive(httpResponse("https://a.test/2", status: 200), isMainFrame: true)
        tracker.finish(second)

        XCTAssertEqual(all.map(\.error?.code), [-999, nil])
        XCTAssertEqual(all.map(\.response?.statusCode), [nil, 200])
    }

    func testNilNavigationIsIgnoredWhenAmbiguous() {
        tracker.start(NSObject(), url: URL(string: "https://a.test/1"))
        tracker.start(NSObject(), url: URL(string: "https://a.test/2"))

        tracker.fail(nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled))
        tracker.finish(nil)

        XCTAssertEqual(all.map(\.error?.code), [nil, nil])
        XCTAssertEqual(all.map(\.endAt), [nil, nil])
    }

    func testNilNavigationAppliesToTheOnlyActiveOne() {
        tracker.start(NSObject(), url: URL(string: "https://a.test/1"))

        tracker.finish(nil)

        XCTAssertNotNil(all.first?.endAt)
    }

    // MARK: - Gate and decision handler

    func testDecisionHandlerWithLoggingDisabledPassesPolicyAndDoesNotReport() {
        NetworkViewer.WebViewTracker.isEnabled = false
        var post = URLRequest(url: URL(string: "https://a.test/")!)
        post.httpMethod = "POST"
        var policies: [WKNavigationActionPolicy] = []

        let handler = tracker.decisionHandler({ policies.append($0) }, request: post, isMainFrame: true)
        handler(.allow)
        tracker.start(NSObject(), url: URL(string: "https://a.test/"))

        XCTAssertEqual(policies, [.allow])
        XCTAssertEqual(all.map(\.request.method), [""])
    }

    func testDecisionHandlerWithLoggingEnabledReportsThenPassesPolicyOnce() {
        NetworkViewer.WebViewTracker.isEnabled = true
        var post = URLRequest(url: URL(string: "https://a.test/")!)
        post.httpMethod = "POST"
        var policies: [WKNavigationActionPolicy] = []

        let allow = tracker.decisionHandler({ policies.append($0) }, request: post, isMainFrame: true)
        allow(.allow)
        tracker.start(NSObject(), url: URL(string: "https://a.test/"))
        let cancel = tracker.decisionHandler({ policies.append($0) }, request: post, isMainFrame: true)
        cancel(.cancel)
        tracker.start(NSObject(), url: URL(string: "https://a.test/"))

        XCTAssertEqual(policies, [.allow, .cancel])
        XCTAssertEqual(all.map(\.request.method), ["POST", ""])
    }

    func testDisabledGateIgnoresWebKitEvents() {
        NetworkViewer.WebViewTracker.isEnabled = false

        tracker.didFinish(nil)
        tracker.didFail(nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled))
        tracker.start(NSObject(), url: URL(string: "https://a.test/"))
        tracker.didFinish(nil)

        XCTAssertEqual(all.map(\.endAt), [nil])
    }

    // MARK: - Default sink

    func testDefaultTrackerWritesOperationsToNetworkViewer() {
        NetworkViewer.deleteAllOperations()
        let tracker = NetworkViewer.WebViewTracker()
        let navigation = NSObject()

        tracker.start(navigation, url: URL(string: "https://a.test/")!)
        tracker.finish(navigation)

        XCTAssertEqual(NetworkViewer.operations.map(\.request.url), ["https://a.test/"])
        XCTAssertNotNil(NetworkViewer.operations.first?.endAt)
        XCTAssertTrue(NetworkViewer.operations.first?.isFromWebView == true)
    }

    // MARK: - Helpers

    private func httpResponse(_ url: String, status: Int, headers: [String: String] = [:]) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: url)!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
    }
}
