import XCTest
import Combine
@testable import NetworkViewer

final class OperationStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NetworkViewer.deleteAllOperations()
        drainMainQueue()
    }

    override func tearDown() {
        NetworkViewer.deleteAllOperations()
        drainMainQueue()
        super.tearDown()
    }

    func testUpdateOperationReplacesOperationWithSameIdInPlace() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1"))
        NetworkViewer.addOperation(.make(id: "2", url: "https://a.test/2"))

        NetworkViewer.updateOperation(.make(id: "1", url: "https://a.test/1", statusCode: 404, endAt: 2))
        drainMainQueue()

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["1", "2"])
        XCTAssertEqual(NetworkViewer.operations[0].response?.statusCode, 404)
        XCTAssertEqual(NetworkViewer.operations[0].endAt, 2)
    }

    func testChangesFromBackgroundThreadAreAppliedOnMainThread() {
        let applied = expectation(description: "applied")
        var changedOnMain: [Bool] = []
        let subscription = NetworkViewer.operationsDidChange.sink {
            changedOnMain.append(Thread.isMainThread)
            if changedOnMain.count == 2 { applied.fulfill() }
        }

        DispatchQueue.global().async {
            NetworkViewer.addOperation(.make(id: "1"))
            NetworkViewer.updateOperation(.make(id: "1", statusCode: 200, endAt: 2))
        }

        wait(for: [applied], timeout: 2)
        subscription.cancel()
        XCTAssertEqual(changedOnMain, [true, true])
        XCTAssertEqual(NetworkViewer.operations.map(\.response?.statusCode), [200])
    }

    func testChangesFromDifferentThreadsKeepCallOrder() {
        let added = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            NetworkViewer.addOperation(.make(id: "1"))
            added.signal()
        }
        added.wait()

        NetworkViewer.updateOperation(.make(id: "1", statusCode: 200, endAt: 2))
        drainMainQueue()

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["1"])
        XCTAssertEqual(NetworkViewer.operations.first?.response?.statusCode, 200)
    }

    func testUpdateOperationIgnoresUnknownOperation() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1"))

        NetworkViewer.updateOperation(.make(id: "2", url: "https://a.test/2"))
        drainMainQueue()

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["1"])
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

extension XCTestCase {

    /// Store changes are applied asynchronously on the main queue; waits until the queued ones have run.
    func drainMainQueue() {
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
    }
}
