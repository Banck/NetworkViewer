//
//  StandardListPaddingModifier.swift
//
//  Created by Sakhabaev Egor on 29.10.2023.
//

import Foundation
import SwiftUI

struct StandardListPaddingModifier: ViewModifier {

    public func body(content: Content) -> some View {
        content
            .listRowInsets(.zero)
            .padding(.init(top: 11, leading: 16, bottom: 11, trailing: 16))
    }
}

extension View {

    func standardListPadding() -> some View {
        modifier(StandardListPaddingModifier())
    }
}
