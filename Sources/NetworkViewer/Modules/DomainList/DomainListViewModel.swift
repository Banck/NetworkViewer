//
//  File.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

class DomainListViewModel: DomainListViewModelInterface, ObservableObject {
    
    private var output: DomainListModuleOutput?
    private let domainList: [DomainData]
    @Published var domainsData: [SettingsDetailedRow.Data]

    init(domainList: [DomainData], output: DomainListModuleOutput? = nil) {
        self.output = output
        self.domainList = domainList
        self.domainsData = domainList.map {
            .init(
                id: $0.domain,
                icon: .init(image: .init(systemName: "folder")!, color: .blue),
                title: $0.domain,
                detail: $0.operationsCount.description,
                disclosureIndicator: true
            )
        }
    }
}

// MARK: - DomainListModuleInput
extension DomainListViewModel: DomainListModuleInput { }
