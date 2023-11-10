//
//  ViewDidLoadModifier.swift
//
//  Created by Sakhabaev Egor on 09.11.2023.
//

import Foundation
import SwiftUI

struct ViewDidLoadModifier: ViewModifier {

    @State private var viewDidLoad = false
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !viewDidLoad else { return }
                viewDidLoad = true
                action?()
            }
    }
}

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(action: action))
    }
}
