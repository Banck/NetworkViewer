//
//  TopIconBottomTextStyle.swift
//
//
//  Created by Sakhabaev Egor on 21.11.2023.
//

import SwiftUI

struct TopIconBottomTextStyle: LabelStyle {

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon
            configuration.title
        }
    }
}
