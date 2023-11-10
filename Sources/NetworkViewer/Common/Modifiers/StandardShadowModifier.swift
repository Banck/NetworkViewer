//
//  StandardShadow.swift
//
//  Created by Sakhabaev Egor on 15.10.2023.
//

import Foundation
import SwiftUI

public struct StandardShadowModifier: ViewModifier {

    public func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0.0, y: 1.0)
    }
}

public extension View {

    func standardShadow() -> some View {
        modifier(StandardShadowModifier())
    }
}
