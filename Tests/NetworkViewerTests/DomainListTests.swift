import XCTest
import SwiftUI
@testable import NetworkViewer

final class DomainListTests: XCTestCase {

    func testDomainWithErrorAfterSuccessfulResponseIsMarkedFailed() {
        let viewModel = DomainListViewModel(operations: [
            .make(statusCode: 200, error: .init(code: -1001, message: "Timed out"), endAt: 2)
        ])
        viewModel.viewWillAppear()

        XCTAssertEqual(viewModel.domainsData.first?.cellData.icon?.color, .yellow)
    }

    func testDomainWithSuccessfulResponsesIsNotMarkedFailed() {
        let viewModel = DomainListViewModel(operations: [.make(statusCode: 200, endAt: 2)])
        viewModel.viewWillAppear()

        XCTAssertEqual(viewModel.domainsData.first?.cellData.icon?.color, .blue)
    }
}
