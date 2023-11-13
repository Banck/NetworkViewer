//
//  OperationScreen.swift
//
//  Created Sakhabaev Egor on 10.11.2023.
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/SwiftUI-MVVM-Coordinator-template
//

import SwiftUI

struct OperationScreen: View, OperationView {

    @StateObject var viewModel: OperationViewModel

    var body: some View {
        Text("Hello")
            .onAppear {
                viewModel.viewWillAppear()
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
    let module = OperationConfigurator.createModule(operation: googleOperation)
    return module.view
}
