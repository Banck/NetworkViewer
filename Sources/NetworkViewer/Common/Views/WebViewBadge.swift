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

extension OperationStatus.Tone {

    var color: Color {
        switch self {
        case .success:
            return .green
        case .failure:
            return .red
        case .neutral:
            return .gray
        }
    }
}

extension OperationStatus.Tone {

    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "xmark.circle.fill"
        case .neutral:
            return "circle.dashed"
        }
    }
}
