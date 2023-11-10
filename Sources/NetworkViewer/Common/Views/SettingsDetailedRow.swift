//
//  DetailedRow.swift
//
//  Created by Sakhabaev Egor on 23.10.2023.
//

import Foundation
import SwiftUI

public struct SettingsDetailedRow: View {

    public struct Data: RowIdentifible {

        public var id: String
        public let title: String
        public var detail: String?
        public var disclosureIndicator: Bool

        public init(
            id: String? = nil,
            title: String,
            detail: String? = nil,
            disclosureIndicator: Bool = false
        ) {
            self.id = id ?? title
            self.title = title
            self.detail = detail
            self.disclosureIndicator = disclosureIndicator
        }
    }

    private let data: Data

    // "proxy" size
    @State private var contentSize: CGSize = .zero
    @State private var selectedValue: String = "A"

    public init(data: Data) {
        self.data = data
    }

    public var body: some View {
        HStack() {
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
    SettingsDetailedRow(
        data: .init(
            id: nil,
            title: "Test Title",
            detail: "Test Detail",
            disclosureIndicator: true
        )
    )
}
