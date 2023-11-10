//
//  OperationProtocols.swift
//  Olimp
//
//  Created Sakhabaev Egor on 10.11.2023.
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/SwiftUI-MVVM-Coordinator-template
//

import Foundation
import SwiftUI

// MARK: - OperationModuleInput
protocol OperationModuleInput: AnyObject { }

// MARK: - OperationModuleOutput
struct OperationModuleOutput {
    
//    let didSelectSearchResult: (_ searchResult: String) -> Void
}

// MARK: - Presenter
protocol OperationViewModelInterface: ObservableObject {

    // MARK: - Lifecycle
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
}

extension OperationViewModelInterface {

    func viewDidLoad() {/*leaves this empty*/}
    func viewWillAppear() {/*leaves this empty*/}
    func viewWillDisappear() {/*leaves this empty*/}
}

// MARK: - View
protocol OperationView {

}
