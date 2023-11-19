//
//  File.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation
import SwiftUI

class DomainListViewModel: DomainListViewModelInterface, ObservableObject {
    
    private var output: DomainListModuleOutput?
    private var operations: [NetworkViewer.Operation] {
        didSet {
            applyFilters()
        }
    }
    private var filteredOperations: [NetworkViewer.Operation] {
        didSet {
            prepareDomainsData()
        }
    }

    private var operationsByDomain: [String: [NetworkViewer.Operation]] {
        Dictionary(grouping: filteredOperations) { URL(string: $0.request.url)?.host ?? $0.request.url }
    }

    @Published var domainsData: [DomainData] = []
    @Published var searchText: String = ""

    var pinnedDomainCellsData: [SettingsDetailedRow.Data] {
        domainsData.filter(\.isPinned).map(\.cellData)
    }
    var unpinnedDomainCellsData: [SettingsDetailedRow.Data] {
        domainsData.filter { !$0.isPinned }.map(\.cellData)
    }

    init(
        operations: [NetworkViewer.Operation],
        output: DomainListModuleOutput? = nil
    ) {
        self.operations = operations
        self.filteredOperations = operations
        self.output = output
    }

    func operations(forDomain domain: String) -> [NetworkViewer.Operation] {
        operationsByDomain[domain] ?? []
    }

    func deleteAllOperations() {
        NetworkViewer.deleteAllOperations()
        operations.removeAll()
    }

    func didChangeSearchText() {
        print("hello")
        applyFilters()
    }

    // MARK: - Lifecycle -
    func viewWillAppear() {
        prepareDomainsData()
    }
}

// MARK: - Private methods
private extension DomainListViewModel {

    func prepareDomainsData() {
        domainsData = operationsByDomain
            .sorted { lhs, rhs in
                let lhsMin = lhs.value.min { $0.startAt < $1.startAt }
                let rhsMin = rhs.value.min { $0.startAt < $1.startAt }
                return (lhsMin?.startAt ?? 0) > (rhsMin?.startAt ?? 0)
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
                        isPinned: NetworkViewer.favoriteService.isFavorite(domain)
                    )
            }
    }

    func applyFilters() {
        withAnimation {
            if searchText.isEmpty {
                filteredOperations = operations
            } else {
                filteredOperations = operations.filter {
                    $0.request.url.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
}

// MARK: - DomainListModuleInput
extension DomainListViewModel: DomainListModuleInput {
    
    func updateOperations(_ operations: [NetworkViewer.Operation]) {
        withAnimation {
            self.operations = operations
        }
    }
}
