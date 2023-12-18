//
//  VDetailedRow.swift
//
//
//  Created by Ivan Ipatov on 13.12.2023.
//

import Foundation
import SwiftUI

struct VDetailedRow: View {

    private let data: Data

    init(data: Data) {
        self.data = data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: data.spacing) {
            Text(data.title.text)
                .font(data.title.font ?? .system(size: 17, weight: .medium))
                .foregroundColor(.primary)
            if let detail = data.detail, !detail.text.isEmpty {
                Text(detail.text)
                    .font(detail.font ?? .system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .standardListPadding()
    }
}

extension VDetailedRow {

    struct Data: RowIdentifible {

        struct TextData {
            let text: String
            let font: Font?

            init(text: String, font: Font? = nil) {
                self.text = text
                self.font = font
            }
        }

        var id: String
        let title: TextData
        var detail: TextData?
        var spacing: CGFloat

        init(
            id: String? = nil,
            title: TextData,
            detail: TextData? = nil,
            spacing: CGFloat = 8.0
        ) {
            self.id = id ?? title.text
            self.title = title
            self.detail = detail
            self.spacing = spacing
        }
    }
}

#Preview {
    List {
        VDetailedRow(
            data: .init(
                id: nil,
                title: .init(text: "Test title"),
                detail: .init(text: "Test detail")
            )
        )
        VDetailedRow(
            data: .init(
                id: nil,
                title: .init(text: "Long long long long title"),
                detail: .init(text: "Short detail")
            )
        )
        VDetailedRow(
            data: .init(
                id: nil,
                title: .init(text: "Long long long long title"),
                detail: .init(text: "Long long long long long long Detail")
            )
        )
        VDetailedRow(
            data: .init(
                id: nil,
                title: .init(text: "Title"),
                detail: .init(text: "Long long long long long long Detail")
            )
        )
    }
}
