//
//  RainbowDebugModifier.swift
//
//  Created by Sakhabaev Egor on 29.10.2023.
//

import Foundation
import SwiftUI

private let rainbowDebugColors = [Color.purple, Color.blue, Color.green, Color.yellow, Color.orange, Color.red]

public extension View {

    /// Useful modifier for debugging view redrawing
    @ViewBuilder
    func rainbowDebug() -> some View {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            background(rainbowDebugColors.randomElement()!)
        } else {
            self
        }
    }
}
