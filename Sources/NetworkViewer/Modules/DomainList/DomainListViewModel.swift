//
//  File.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

class DomainListViewModel: DomainListViewModelInterface, ObservableObject {
    
    private var output: DomainListModuleOutput?
    private let operations: [NetworkViewer.Operation]
    private var operationsByDomain: [String: [NetworkViewer.Operation]] {
        Dictionary(grouping: operations) { URL(string: $0.request.url)?.host ?? $0.request.url }
    }
    
    @Published var domainsData: [DomainData] = []
    var pinnedDomainCellsData: [SettingsDetailedRow.Data] {
        domainsData.filter(\.isPinned).map(\.cellData)
    }
    var unpinnedDomainCellsData: [SettingsDetailedRow.Data] {
        domainsData.filter { !$0.isPinned }.map(\.cellData)
    }

    init(operations: [NetworkViewer.Operation], output: DomainListModuleOutput? = nil) {
        self.output = output
        self.operations = operations
        prepareDomainsData()
    }

    func operations(forDomain domain: String) -> [NetworkViewer.Operation] {
        operationsByDomain[domain] ?? []
    }
}

// MARK: - Private methods
private extension DomainListViewModel {

    func prepareDomainsData() {
        domainsData = operationsByDomain
            .sorted { lhs, rhs in
                let lhsMin = lhs.value.min { $0.startAt > $1.startAt }
                let rhsMin = rhs.value.min { $0.startAt > $1.startAt }
                return (lhsMin?.startAt ?? 0) < (rhsMin?.startAt ?? 0)
            }
            .map { (domain: String, operations: [NetworkViewer.Operation]) in
                    .init(
                        cellData: .init(
                            id: domain,
                            icon: .init(image: .init(systemName: "folder")!, color: .blue),
                            title: .init(text: domain),
                            detail: .init(text: operations.count.description),
                            disclosureIndicator: true
                        ),
                        isPinned: false
                    )

            }
    }
}

// MARK: - DomainListModuleInput
extension DomainListViewModel: DomainListModuleInput { }
