//
//  TintModifier.swift
//
//  Created by Sakhabaev Egor on 29.10.2023.
//

import Foundation
import SwiftUI

/// Wrapper for .tint iOS 16+.
public struct TintModifier: ViewModifier {

    public var color: Color

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.tint(color)
        } else {
            content
        }
    }
}

public extension View {

    /// Wrapper for .tint iOS 16+.
    func tintColor(_ color: Color) -> some View {
        modifier(TintModifier(color: color))
    }
}
