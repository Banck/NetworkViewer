//
//  viShareButton.swift
//
//
//  Created by Ivan Ipatov on 15.12.2023.
//

import SwiftUI

struct viShareButton<ContentView: View>: View where ContentView: View {

    let contentView: () -> ContentView
    let data: String

    init(
        @ViewBuilder contentView: @escaping () -> ContentView,
        data: String
    ) {
        self.contentView = contentView
        self.data = data
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            ShareLink(items: [data]) {
                contentView()
            }
        } else {
            Button {
                UIPasteboard.general.string = data
            } label: {
                contentView()
            }
        }
    }
}
