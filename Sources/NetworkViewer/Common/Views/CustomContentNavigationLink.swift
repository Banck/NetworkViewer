//
//  CustomContentNavigationLink.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import SwiftUI

struct CustomContentNavigationLink<ContentView: View, Destination: View>: View {

    let contentView: () -> ContentView
    let destination: () -> Destination

    init(
        @ViewBuilder contentView: @escaping () -> ContentView,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.contentView = contentView
        self.destination = destination
    }

    init(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> ContentView
    ) {
        self.init(contentView: label, destination: destination)
    }


    var body: some View {
        ZStack {
            NavigationLink(destination: {
                destination()
            }, label: {
                EmptyView()
            })
            .opacity(0)
            contentView()
        }
    }
}
