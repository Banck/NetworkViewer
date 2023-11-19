//
//  DomainListScreen.swift
//
//  Created Sakhabaev Egor on 10.11.2023.
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/SwiftUI-Coordinator-template
//

import SwiftUI

struct DomainListScreen: View {

    @StateObject var viewModel: DomainListViewModel

    var body: some View {
        viNavigationStack {
            List() {
                sectionForDomains(isPinned: true)
                sectionForDomains(isPinned: false)
            }
            .navigationTitle("Domains")
            .viSearchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.didChangeSearchText()
            }
            .toolbar {
                Button {
                    viewModel.deleteAllOperations()
                } label: {
                    Image(systemName: "trash")
                }
            }
            .onAppear {
                viewModel.viewWillAppear()
            }
        }
    }

    @ViewBuilder
    func sectionForDomains(isPinned: Bool) -> some View {
        let cellsData = isPinned
        ? viewModel.pinnedDomainCellsData
        : viewModel.unpinnedDomainCellsData
        if cellsData.isEmpty {
            EmptyView()
        } else {
            Section {
                ForEach(cellsData, id: \.id) { data in
                    CustomContentNavigationLink(
                        contentView: {
                            SettingsDetailedRow(data: data)
                        },
                        destination: {
                            OperationListConfigurator.createModule(operations: viewModel.operations(forDomain: data.id)).view
                        }
                    )
                    .listRowInsets(.zero)
                }
            } header: {
                if isPinned {
                    HStack {
                        Image(systemName: "pin.fill")
                        Text("Pinned")
                    }
                }
            } footer: { }
        }
    }
}


#Preview {
    let googleOperation = NetworkViewer.Operation(
        id: UUID().uuidString,
        request: .init(url: "https://google.com", method: "POST", headers: [:], body: nil),
        response: nil,
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970,
        endAt: Date().timeIntervalSince1970 + 60
    )
    let appleOperation = NetworkViewer.Operation(
        id: UUID().uuidString,
        request: .init(url: "https://apple.com", method: "GET", headers: [:], body: nil),
        response: .init(statusCode: 200, headers: [:]),
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970 - 30,
        endAt: Date().timeIntervalSince1970 + 30
    )
    let appleSecondOperation = NetworkViewer.Operation(
        id: UUID().uuidString,
        request: .init(url: "https://apple.com", method: "GET", headers: [:], body: nil),
        response: nil,
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970 + 10,
        endAt: Date().timeIntervalSince1970 + 30
    )

    let operations: [NetworkViewer.Operation] = [
        googleOperation, appleOperation, appleSecondOperation
    ]
    let module = DomainListConfigurator.createModule(operations: operations)
    return module.view
}
