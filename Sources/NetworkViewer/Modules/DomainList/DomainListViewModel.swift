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
        Dictionary(grouping: filteredOperations) {
            (URL(string: $0.request.url)?.host ?? $0.request.url) + ($0.isFromWebView ? " " : "")
        }
    }

    @Published var domainsData: [DomainData] = []
    @Published var searchText: String = ""

    var pinnedDomainCellsData: [HDetailedRow.Data] {
        domainsData.filter(\.isPinned).map(\.cellData)
    }
    var unpinnedDomainCellsData: [HDetailedRow.Data] {
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
    
    func getAllOperations() -> [NetworkViewer.Operation] {
        operations
    }

    func operations(forDomain domain: String) -> [NetworkViewer.Operation] {
        operationsByDomain[domain] ?? []
    }

    func deleteAllOperations() {
        NetworkViewer.deleteAllOperations()
        operations.removeAll()
    }

    func didChangeSearchText() {
        applyFilters()
    }

    func didSelectCopyURL(forId id: String) {
        UIPasteboard.general.string = id
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
                let icon: HDetailedRow.Data.Icon
                let hasFailedRequest = operations.contains { $0.error != nil || ($0.response?.statusCode ?? 200) > 400 }
                
                if operations.contains(where: { $0.isFromWebView }) {
                    icon = .init(image: .init(systemName: "globe")!, color: .blue)
                } else if hasFailedRequest  {
                    icon = .init(image: .init(systemName: "exclamationmark.triangle")!, color: .yellow)
                } else {
                    icon = .init(image: .init(systemName: "folder")!, color: .blue)
                }
                
                return DomainData(
                        cellData: .init(
                            id: domain,
                            icon: icon,
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
