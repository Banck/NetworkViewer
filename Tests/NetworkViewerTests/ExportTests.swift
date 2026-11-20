import XCTest
@testable import NetworkViewer

final class ExportTests: XCTestCase {

    // MARK: - cURL

    func testCurlOmitsMethodWhenItIsUnknown() {
        for method in ["", "-"] {
            let curl = NetworkViewer.Request(url: "https://a.test/next", method: method, headers: [:], body: nil).cURL

            XCTAssertEqual(curl, #"curl "https://a.test/next""#, "method: \(method)")
        }
    }

    func testCurlKeepsKnownMethod() {
        let curl = NetworkViewer.Request(url: "https://a.test", method: "POST", headers: [:], body: nil).cURL

        XCTAssertEqual(curl, "curl \"https://a.test\" \\\n\t-X POST")
    }

    // MARK: - HAR

    func testHARKeepsResponseAndAddsErrorWhenBothPresent() throws {
        let entry = try harEntry(for: .make(
            statusCode: 200,
            responseHeaders: ["Content-Type": "text/html"],
            error: .init(code: 102, message: "Frame load interrupted"),
            endAt: 2,
            isFromWebView: true
        ))
        let response = try XCTUnwrap(entry["response"] as? [String: Any])

        XCTAssertEqual(response["status"] as? Int, 200)
        XCTAssertEqual(response["statusText"] as? String, "OK")
        XCTAssertEqual(response["headers"] as? [[String: String]], [["name": "Content-Type", "value": "text/html"]])
        XCTAssertEqual(entry["_error"] as? [String: AnyHashable], ["code": 102, "message": "Frame load interrupted"])
    }

    func testHARErrorWithoutResponseUsesErrorCodeAndMessage() throws {
        let entry = try harEntry(for: .make(
            error: .init(code: -1009, message: "Offline"),
            endAt: 2
        ))
        let response = try XCTUnwrap(entry["response"] as? [String: Any])

        XCTAssertEqual(response["status"] as? Int, -1009)
        XCTAssertEqual(response["statusText"] as? String, "Offline")
        XCTAssertEqual(entry["_error"] as? [String: AnyHashable], ["code": -1009, "message": "Offline"])
    }

    func testHARRedirectAndUnknownMethod() throws {
        let entry = try harEntry(for: .make(
            method: "",
            endAt: 2,
            isFromWebView: true,
            redirectURL: "https://b.test/next"
        ))
        let request = try XCTUnwrap(entry["request"] as? [String: Any])
        let response = try XCTUnwrap(entry["response"] as? [String: Any])

        XCTAssertEqual(request["method"] as? String, "")
        XCTAssertEqual(response["status"] as? Int, 0)
        XCTAssertEqual(response["statusText"] as? String, "Redirect → https://b.test/next")
        XCTAssertNil(entry["_error"])
    }

    // MARK: - JSON

    func testJSONUsesOperationStatusAndEmptyUnknownMethod() throws {
        let json = OperationMapper.jsonFrom(.make(
            method: "-",
            endAt: 2,
            isFromWebView: true,
            redirectURL: "https://b.test/next"
        ))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any])

        XCTAssertEqual(object["status"] as? String, "Redirect → https://b.test/next")
        XCTAssertEqual(object["method"] as? String, "")
    }

    private func harEntry(for operation: NetworkViewer.Operation) throws -> [String: Any] {
        let har = try XCTUnwrap(OperationsToHARDataHandler().process([operation]))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(har.utf8)) as? [String: Any])
        let log = try XCTUnwrap(object["log"] as? [String: Any])
        let entries = try XCTUnwrap(log["entries"] as? [[String: Any]])
        return try XCTUnwrap(entries.first)
    }
}
