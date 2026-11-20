import XCTest
@testable import NetworkViewer

final class OperationListLiveUpdateTests: XCTestCase {

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

    func testOpenListShowsCompletedOperationAfterUpdate() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/page"))
        drainMainQueue()
        let viewModel = makeListViewModel(domain: "a.test")
        viewModel.viewDidLoad()

        NetworkViewer.updateOperation(.make(id: "1", url: "https://a.test/page", statusCode: 404, endAt: 2))
        drainMainQueue()

        XCTAssertEqual(viewModel.operationsData.map(\.status), ["404 Not Found"])
        XCTAssertEqual(viewModel.operation(forId: "1")?.response?.statusCode, 404)
    }

    func testOpenListShowsNewOperationsOfItsDomainOnly() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1", startAt: 1))
        drainMainQueue()
        let viewModel = makeListViewModel(domain: "a.test")
        viewModel.viewDidLoad()

        NetworkViewer.addOperation(.make(id: "2", url: "https://a.test/2", startAt: 2))
        NetworkViewer.addOperation(.make(id: "3", url: "https://b.test/3", startAt: 3))
        NetworkViewer.addOperation(.make(id: "4", url: "https://a.test/4", startAt: 4, isFromWebView: true))
        drainMainQueue()

        XCTAssertEqual(viewModel.operationsData.map(\.id), ["2", "1"])
    }

    func testWebViewDomainListContainsOnlyWebViewOperations() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/1", isFromWebView: true))
        NetworkViewer.addOperation(.make(id: "2", url: "https://a.test/2"))
        drainMainQueue()

        let viewModel = makeListViewModel(domain: NetworkViewer.Operation.make(url: "https://a.test", isFromWebView: true).domainKey)
        viewModel.viewDidLoad()

        XCTAssertEqual(viewModel.operationsData.map(\.id), ["1"])
    }

    func testOpenListKeepsDomainSearchFilter() {
        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/login"))
        drainMainQueue()
        let viewModel = makeListViewModel(domain: "a.test", domainSearchText: "login")
        viewModel.viewDidLoad()

        NetworkViewer.addOperation(.make(id: "2", url: "https://a.test/other", startAt: 2))
        drainMainQueue()

        XCTAssertEqual(viewModel.operationsData.map(\.id), ["1"])
    }

    func testDeletingWebViewGroupKeepsNativeOperationsOfSameHost() {
        NetworkViewer.addOperation(.make(id: "native", url: "https://a.test/api"))
        NetworkViewer.addOperation(.make(id: "web", url: "https://a.test/page", isFromWebView: true))
        drainMainQueue()
        let webList = makeListViewModel(domain: NetworkViewer.operations[1].domainKey)

        webList.deleteDomainOperations()
        drainMainQueue()

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["native"])
    }

    func testDeletingNativeGroupKeepsWebViewOperationsOfSameHost() {
        NetworkViewer.addOperation(.make(id: "native", url: "https://a.test/api"))
        NetworkViewer.addOperation(.make(id: "web", url: "https://a.test/page", isFromWebView: true))
        drainMainQueue()
        let nativeList = makeListViewModel(domain: NetworkViewer.operations[0].domainKey)

        nativeList.deleteDomainOperations()
        drainMainQueue()

        XCTAssertEqual(NetworkViewer.operations.map(\.id), ["web"])
    }

    func testReleasedListIsNotRetainedBySubscription() {
        weak var released: OperationListViewModel?
        autoreleasepool {
            let viewModel = makeListViewModel(domain: "a.test")
            released = viewModel
        }

        NetworkViewer.addOperation(.make(id: "1", url: "https://a.test/page"))
        drainMainQueue()

        XCTAssertNil(released)
    }

    private func makeListViewModel(domain: String, domainSearchText: String = "") -> OperationListViewModel {
        OperationListViewModel(domainKey: domain, domainSearchText: domainSearchText)
    }
}
