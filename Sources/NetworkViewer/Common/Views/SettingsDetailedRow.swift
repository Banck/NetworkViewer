//
//  DetailedRow.swift
//
//  Created by Sakhabaev Egor on 23.10.2023.
//

import Foundation
import SwiftUI

struct SettingsDetailedRow: View {

    private let data: Data

    // "proxy" size
    @State private var contentSize: CGSize?

    init(data: Data) {
        self.data = data
    }

    var body: some View {
        HStack() {
            if let icon = data.icon {
                Image(uiImage: icon.image)
                    .renderingMode(icon.color != nil ? .template : .original)
                    .foregroundColor(icon.color)
            }
            Text(data.title.text)
                .font(data.title.font ?? .system(size: 17, weight: .medium))
                .frame(
                    maxWidth: contentSize?.width,
                    alignment: .leading
                )
            Spacer()
            if let detail = data.detail, !detail.text.isEmpty {
                Text(detail.text)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .font(detail.font ?? .system(size: 15))
                    .foregroundColor(.secondary)
            }
            if data.disclosureIndicator {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .standardListPadding()
        // Hack to make whole view tappable for onTapGesture
        .contentShape(Rectangle())
        // Hack to get content size of row
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        contentSize = geometry.frame(in: .global).size
                    }
            }
        )
    }
}

extension SettingsDetailedRow {

    struct Data: RowIdentifible {

        struct Icon {
            let image: UIImage
            let color: Color?
        }

        struct TextData {
            let text: String
            let font: Font?

            init(text: String, font: Font? = nil) {
                self.text = text
                self.font = font
            }
        }

        var id: String
        let icon: Icon?
        let title: TextData
        var detail: TextData?
        var disclosureIndicator: Bool

        init(
            id: String? = nil,
            icon: Icon? = nil,
            title: TextData,
            detail: TextData? = nil,
            disclosureIndicator: Bool = false
        ) {
            self.id = id ?? title.text
            self.icon = icon
            self.title = title
            self.detail = detail
            self.disclosureIndicator = disclosureIndicator
        }
    }
}


#Preview {
    List {
        SettingsDetailedRow(
            data: .init(
                id: nil,
                icon: .init(
                    image: .init(systemName: "folder")!,
                    color: .blue
                ),
                title: .init(text: "Test title"),
                detail: .init(text: "Test detail"),
                disclosureIndicator: true
            )
        )
        SettingsDetailedRow(
            data: .init(
                id: nil,
                icon: .init(
                    image: .init(systemName: "folder")!,
                    color: .blue
                ),
                title: .init(text: "Long long long long title"),
                detail: .init(text: "Short detail"),
                disclosureIndicator: true
            )
        )
        SettingsDetailedRow(
            data: .init(
                id: nil,
                icon: .init(
                    image: .init(systemName: "folder")!,
                    color: .blue
                ),
                title: .init(text: "Long long long long title"),
                detail: .init(text: "Long long long long long long Detail"),
                disclosureIndicator: true
            )
        )
        SettingsDetailedRow(
            data: .init(
                id: nil,
                icon: .init(
                    image: .init(systemName: "network")!,
                    color: .blue
                ),
                title: .init(text: "Title"),
                detail: .init(text: "Long long long long long long Detail"),
                disclosureIndicator: true
            )
        )
    }
}
