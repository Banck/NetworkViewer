//
//  DetailedRow.swift
//
//  Created by Sakhabaev Egor on 23.10.2023.
//

import Foundation
import SwiftUI

struct SettingsDetailedRow: View {

    struct Data: RowIdentifible {

        struct Icon {
            let image: UIImage
            let color: Color?
        }

        var id: String
        let icon: Icon?
        let title: String
        var detail: String?
        var disclosureIndicator: Bool

        init(
            id: String? = nil,
            icon: Icon? = nil,
            title: String,
            detail: String? = nil,
            disclosureIndicator: Bool = false
        ) {
            self.id = id ?? title
            self.icon = icon
            self.title = title
            self.detail = detail
            self.disclosureIndicator = disclosureIndicator
        }
    }

    private let data: Data

    // "proxy" size
    @State private var contentSize: CGSize = .zero

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
            Text(data.title)
                .font(.system(size: 17, weight: .medium))
                .frame(
                    maxWidth: contentSize.width / 2,
                    alignment: .leading
                )
            Spacer()
            if let detail = data.detail, !detail.isEmpty {
                Text(detail)
                    .frame(
                        maxWidth: contentSize.width / 2,
                        alignment: .trailing
                    )
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .font(.system(size: 15))
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

#Preview {
    List {
        SettingsDetailedRow(
            data: .init(
                id: nil,
                icon: .init(
                    image: .init(systemName: "folder")!,
                    color: .blue
                ),
                title: "Test Title",
                detail: "Test Detail",
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
                title: "Test Title",
                detail: "Test Detail",
                disclosureIndicator: true
            )
        )
    }
}
