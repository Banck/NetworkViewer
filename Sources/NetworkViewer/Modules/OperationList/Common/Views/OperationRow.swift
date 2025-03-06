//
//  OperationRow.swift
//
//
//  Created by Sakhabaev Egor on 11.11.2023.
//

import SwiftUI

struct OperationRow: View {

    private let data: Data

    init(data: Data) {
        self.data = data
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if !data.isFromWebView {
                    Circle()
                        .fixedSize()
                        .foregroundColor(data.success ? .green : .red)
                    Text(data.method)
                        .font(.system(size: 14, weight: .medium))
                    secondaryText(data.status)
                    secondaryText(data.date)
                    if let duration = data.duration {
                        secondaryText(duration)
                    }
                } else {
                    Text(data.method)
                        .font(.system(size: 14, weight: .medium))
                    secondaryText(data.date)
                    if let duration = data.duration {
                        secondaryText(duration)
                    }
                }
            }
            Text("[\(data.url)](\(data.url))")
                .allowsHitTesting(false)
        }
    }

    func secondaryText(_ text: String) -> some View {
        HStack {
            Circle()
                .frame(height: 5, alignment: .center)
                .opacity(0.5)
                .foregroundColor(.secondary)
            Text(text)
                .font(.system(size: 14, weight: .light))
                .lineLimit(1)
                .foregroundColor(.secondary)
                .disabled(true)
        }
    }
}

extension OperationRow {

    struct Data {

        let id: String
        let success: Bool
        let method: String
        let status: String
        let date: String
        let duration: String?
        let url: String
        let isFromWebView: Bool
    }
}

#Preview {
    List {
        OperationRow(
            data: .init(
                id: "1",
                success: true,
                method: "POST",
                status: "200 OK",
                date: "15:18:20",
                duration: "182.122 sec",
                url: "https://google.com/api/images?id=124",
                isFromWebView: false
            )
        )
    }
}
