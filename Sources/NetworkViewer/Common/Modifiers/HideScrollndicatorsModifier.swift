//
//  HideScrollndicatorsViewModifier.swift
//
//  Created by Sakhabaev Egor on 23.10.2023.
//

import Foundation
import SwiftUI

struct HideScrollndicatorsModifier: ViewModifier {

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollIndicators(.hidden)
        } else {
            content
        }
    }
}

extension View {

    func hideScrollIndicators() -> some View {
        modifier(HideScrollndicatorsModifier())
    }
}
