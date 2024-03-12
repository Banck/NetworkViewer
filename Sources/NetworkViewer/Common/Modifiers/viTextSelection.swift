//
//  viTextSelection.swift
//
//
//  Created by Sakhabaev Egor on 12.03.2024.
//

import SwiftUI

struct viTextSelectionModifier: ViewModifier {

    var isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            if isEnabled {
                content
                    .textSelection(.enabled)
            } else {
                content
                    .textSelection(.disabled)
            }
        } else {
            content
        }
    }
}

extension View {

    func viTextSelection(isEnabled: Bool) -> some View {
        modifier(viTextSelectionModifier(isEnabled: isEnabled))
    }
}
