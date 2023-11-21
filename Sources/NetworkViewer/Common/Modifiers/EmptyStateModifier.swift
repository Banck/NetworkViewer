//
//  EmptyStateModifier.swift
//  
//
//  Created by Sakhabaev Egor on 21.11.2023.
//

import SwiftUI

struct EmptyStateModifier<Placeholder>: ViewModifier where Placeholder: View {

    var isEnabled: Bool
    @ViewBuilder var placeholderView: () -> Placeholder

    func body(content: Content) -> some View {
        if isEnabled {
            placeholderView()
        } else {
            content
        }
    }
}

extension View {

    func emptyState(isEnabled: Bool, @ViewBuilder placeholder: @escaping () -> some View) -> some View {
        modifier(EmptyStateModifier(isEnabled: isEnabled, placeholderView: placeholder))
    }
}
