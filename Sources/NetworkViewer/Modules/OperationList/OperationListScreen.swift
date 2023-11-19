//
//  OperationListScreen.swift
//
//  Created Sakhabaev Egor on 10.11.2023.
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/SwiftUI-MVVM-Coordinator-template
//

import SwiftUI

struct OperationListScreen: View, OperationListView {

    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel: OperationListViewModel

    var body: some View {
        List(viewModel.operationsData, id: \.id) { data in
            NavigationLink {
                if let operation = viewModel.operation(forId: data.id) {
                    BodyViewerConfigurator.createModule(data: operation.responseData).view
//                    OperationConfigurator.createModule(operation: operation).view
                } else {
                    EmptyView()
                }
            } label: {
                OperationRow(data: data)
            }
        }
        .listStyle(.inset)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .viSearchable(text: $viewModel.searchText)
        .onChange(of: $viewModel.searchText.wrappedValue) { _ in
            viewModel.didChangeSearchText()
        }
        .toolbar {
            Button {
                viewModel.deleteDomainOperations()
                presentation.wrappedValue.dismiss()
            } label: {
                Image(systemName: "trash")
            }
            Button(
                action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    viewModel.toggleFavorite()
                },
                label: {
                    Image(systemName: viewModel.isFavorite ? "pin.fill" : "pin")
                }
            )
        }
        .onLoad {
            viewModel.viewDidLoad()
        }
        .onAppear {
            viewModel.viewWillAppear()
        }
    }
}

#Preview {
    let firstOperation = NetworkViewer.Operation(
        id: "1",
        request: .init(url: "https://google.com/api/ai", method: "POST", headers: [:], body: nil),
        response: .init(statusCode: 200, headers: [:]),
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970 - 60,
        endAt: Date().timeIntervalSince1970 - 55
    )
    let secondOperation = NetworkViewer.Operation(
        id: "2",
        request: .init(url: "https://google.com/api/images", method: "GET", headers: [:], body: nil),
        response: nil,
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970 - 50,
        endAt: Date().timeIntervalSince1970 - 49.612
    )
    let thirdOperation = NetworkViewer.Operation(
        id: "3",
        request: .init(url: "https://google.com/api/search?text=test", method: "POST", headers: [:], body: nil),
        response: nil,
        responseData: Data(),
        error: nil,
        startAt: Date().timeIntervalSince1970 - 30,
        endAt: Date().timeIntervalSince1970
    )

    let operations: [NetworkViewer.Operation] = [
        firstOperation, secondOperation, thirdOperation
    ]
    let module = OperationListConfigurator.createModule(operations: operations)
    return NavigationView {
        module.view
    }
}
