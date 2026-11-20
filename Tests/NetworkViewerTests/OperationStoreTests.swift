import XCTest
@testable import NetworkViewer

final class OperationStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NetworkViewer.deleteAllOperations()
    }

    override func tearDown() {
        NetworkViewer.deleteAllOperations()
        super.tearDown()
    }

    func testUpdateOperationReplacesOperationWithSameIdInPlace() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1"))
        NetworkViewer.addOperation(.make(id: "2", url: "https://a.test/2"))

        NetworkViewer.updateOperation(.make(id: "1", url: "https://a.test/1", statusCode: 404, endAt: 2))

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["1", "2"])
        XCTAssertEqual(NetworkViewer.operations[0].response?.statusCode, 404)
        XCTAssertEqual(NetworkViewer.operations[0].endAt, 2)
    }

    func testUpdateOperationAppendsUnknownOperation() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1"))

        NetworkViewer.updateOperation(.make(id: "2", url: "https://a.test/2"))

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["1", "2"])
    }
}

extension NetworkViewer.Operation {

    static func make(
        id: String = UUID().uuidString,
        url: String = "https://a.test/path",
        method: String = "GET",
        statusCode: Int? = nil,
        responseHeaders: [String: String] = [:],
        error: NetworkViewer.CustomError? = nil,
        startAt: TimeInterval = 1,
        endAt: TimeInterval? = nil,
        isFromWebView: Bool = false,
        isFromIFrame: Bool = false,
        redirectURL: String? = nil
    ) -> NetworkViewer.Operation {
        NetworkViewer.Operation(
            id: id,
            request: .init(url: url, method: method, headers: [:], body: nil),
            response: statusCode.map { .init(statusCode: $0, headers: responseHeaders) },
            responseData: Data(),
            error: error,
            startAt: startAt,
            endAt: endAt,
            isFromWebView: isFromWebView,
            isFromIFrame: isFromIFrame,
            redirectURL: redirectURL
        )
    }
}
