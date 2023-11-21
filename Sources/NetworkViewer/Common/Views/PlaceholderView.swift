//
//  PlaceholderView.swift
//
//
//  Created by Sakhabaev Egor on 21.11.2023.
//

import SwiftUI

struct PlaceholderView<Label, Description>: View where Label: View, Description: View {

    let label: () -> Label
    let description: () -> Description

    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder description: @escaping () -> Description = { EmptyView() }
    ) {
        self.label = label
        self.description = description
    }

    init(
        _ title: String,
        image name: String,
        description: String? = nil
    ) where Label == SwiftUI.Label<Text, Image>, Description == Text? {
        self.init {
            SwiftUI.Label(title, image: name)
        } description: {
            if let description {
                Text(description)
            }
        }
    }

    init(
        _ title: String,
        systemImage name: String,
        description: String? = nil
    ) where Label == SwiftUI.Label<Text, Image>, Description == Text? {
        self.init {
            SwiftUI.Label(title, systemImage: name)
        } description: {
            if let description {
                Text(description)
            }
        }
    }

    public var body: some View {
        VStack() {
            label()
                .font(.system(size: 26, weight: .bold))
                .labelStyle(PlaceholderTextStyle())
            description()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct PlaceholderTextStyle: LabelStyle {

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 16) {
            configuration.icon
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.secondary)
            configuration.title
        }
    }
}

#Preview {
    PlaceholderView(
        "No mail",
        systemImage: "tray.fill",
        description: "New mails you receive will appear here."
    )
//    PlaceholderView {
//        Label("No Mail", systemImage: "tray.fill")
//    } description: {
//        Text("New mails you receive will appear here.")
//    }
}
