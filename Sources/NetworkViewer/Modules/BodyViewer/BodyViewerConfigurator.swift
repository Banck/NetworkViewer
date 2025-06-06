//
//  BodyViewerConfigurator.swift
//
//  Created Sakhabaev Egor on 10.11.2023.
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/SwiftUI-MVVM-Coordinator-template
//

import UIKit
import SwiftUI

struct BodyViewerConfigurator {

    static func createModule(
        title: String,
        data: Data,
        output: BodyViewerModuleOutput? = nil
    ) -> (view: some View, input: BodyViewerModuleInput) {
        let viewModel = BodyViewerViewModel(title: title, data: data, output: output)
        let view = BodyViewerScreen(viewModel: viewModel)

        return (view, viewModel)
    }
}
