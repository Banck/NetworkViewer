//
//  viNavigationStack.swift
//  NetworkViewer
//
//  Created by Sakhabaev Egor on 15.11.2023.
//

import SwiftUI

struct viNavigationStack<Content>: View where Content: View {

    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(.stack)
        }
    }
}
