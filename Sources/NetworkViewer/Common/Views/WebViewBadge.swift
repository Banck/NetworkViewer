//
//  WebViewBadge.swift
//

import SwiftUI

/// Marks an operation that came from a WebView.
struct WebViewBadge: View {

    let text: String

    var body: some View {
        HStack(spacing: 2.0) {
            Image(systemName: "globe")
            Text(text)
        }
        .font(.system(size: 11.0, weight: .semibold))
        .foregroundColor(.blue)
        .padding(.horizontal, 4.0)
        .padding(.vertical, 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 4.0)
                .stroke(Color.blue, lineWidth: 1.0)
        )
    }
}
