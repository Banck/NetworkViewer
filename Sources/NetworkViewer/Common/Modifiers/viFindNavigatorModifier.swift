//
//  viFindNavigatorModifier.swift
//
//
//  Created by Sakhabaev Egor on 14.11.2023.
//

import SwiftUI

struct viFindNavigatorModifier: ViewModifier {

    let isPresented: Binding<Bool>

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .findNavigator(isPresented: isPresented)
        } else {
            content
        }
    }
}

extension View {

    func viFindNavigator(isPresented: Binding<Bool>) -> some View {
        modifier(viFindNavigatorModifier(isPresented: isPresented))
    }
}
