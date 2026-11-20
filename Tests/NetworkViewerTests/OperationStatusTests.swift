import XCTest
@testable import NetworkViewer

final class OperationStatusTests: XCTestCase {

    func testSuccessfulResponse() {
        let status = OperationStatus(.make(statusCode: 200, endAt: 1.5))

        XCTAssertEqual(status.text, "200 OK")
        XCTAssertEqual(status.tone, .success)
        XCTAssertEqual(status.duration, "500 ms")
        XCTAssertNil(status.errorDescription)
    }

    func testHTTPErrorResponseIsFailure() {
        let status = OperationStatus(.make(statusCode: 404, endAt: 2))

        XCTAssertEqual(status.text, "404 Not Found")
        XCTAssertEqual(status.tone, .failure)
    }

    func testStatusCodeUnknownToEnumIsShownAsIs() {
        let status = OperationStatus(.make(statusCode: 299, endAt: 2))

        XCTAssertEqual(status.text, "299")
        XCTAssertEqual(status.tone, .success)
    }

    func testErrorWithoutResponseShowsCodeAndMessage() {
        let status = OperationStatus(.make(
            error: .init(code: -1009, message: "The Internet connection appears to be offline."),
            endAt: 2
        ))

        XCTAssertEqual(status.text, "Error -1009")
        XCTAssertEqual(status.tone, .failure)
        XCTAssertEqual(status.errorDescription, "-1009: The Internet connection appears to be offline.")
    }

    func testErrorAfterResponseKeepsResponseStatusAndShowsError() {
        let status = OperationStatus(.make(
            statusCode: 200,
            error: .init(code: 102, message: "Frame load interrupted"),
            endAt: 2
        ))

        XCTAssertEqual(status.text, "200 OK")
        XCTAssertEqual(status.tone, .failure)
        XCTAssertEqual(status.errorDescription, "102: Frame load interrupted")
    }

    func testRedirectIsNeutral() {
        let status = OperationStatus(.make(endAt: 2, isFromWebView: true, redirectURL: "https://b.test/next"))

        XCTAssertEqual(status.text, "Redirect → https://b.test/next")
        XCTAssertEqual(status.tone, .neutral)
    }

    func testFinishedWebViewNavigationWithoutResponseIsCacheNotError() {
        let status = OperationStatus(.make(endAt: 2, isFromWebView: true))

        XCTAssertEqual(status.text, "No response (cache)")
        XCTAssertEqual(status.tone, .neutral)
    }

    func testFinishedNativeOperationWithoutResponseStaysUnknownFailure() {
        let status = OperationStatus(.make(endAt: 2))

        XCTAssertEqual(status.text, "Unknown")
        XCTAssertEqual(status.tone, .failure)
    }

    func testUnfinishedOperationIsPending() {
        let status = OperationStatus(.make(isFromWebView: true))

        XCTAssertEqual(status.text, "Pending")
        XCTAssertEqual(status.tone, .neutral)
        XCTAssertNil(status.duration)
    }

    func testIFrameResponseHasNoDuration() {
        let status = OperationStatus(.make(statusCode: 200, startAt: 5, endAt: 5, isFromWebView: true, isFromIFrame: true))

        XCTAssertEqual(status.text, "200 OK")
        XCTAssertNil(status.duration)
    }

    func testDurationUnits() {
        XCTAssertEqual(OperationStatus(.make(statusCode: 200, startAt: 0, endAt: 2.5)).duration, "2.5 sec")
        XCTAssertEqual(OperationStatus(.make(statusCode: 200, startAt: 0, endAt: 150)).duration, "2.5 min")
    }

    func testWebViewRedirectionResponseIsNeutral() {
        let status = OperationStatus(.make(statusCode: 304, endAt: 2, isFromWebView: true))

        XCTAssertEqual(status.text, "304 Not Modified")
        XCTAssertEqual(status.tone, .neutral)
    }

    func testWebViewRedirectionResponseWithErrorIsFailure() {
        let status = OperationStatus(.make(statusCode: 304, error: .init(code: 102, message: "Interrupted"), endAt: 2, isFromWebView: true))

        XCTAssertEqual(status.tone, .failure)
    }

    func testNativeRedirectionResponseStaysFailure() {
        let status = OperationStatus(.make(statusCode: 304, endAt: 2))

        XCTAssertEqual(status.tone, .failure)
    }
}
