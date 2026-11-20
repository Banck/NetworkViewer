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
                Circle()
                    .fixedSize()
                    .foregroundColor(data.tone.color)
                if let webViewBadge = data.webViewBadge {
                    WebViewBadge(text: webViewBadge)
                }
                Text(data.method)
                    .font(.system(size: 14, weight: .medium))
                secondaryText(data.status)
                secondaryText(data.date)
                if let duration = data.duration {
                    secondaryText(duration)
                }
            }
            Text("[\(data.url)](\(data.url))")
                .allowsHitTesting(false)
            if let errorDescription = data.errorDescription {
                Text(errorDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .lineLimit(2)
            }
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
        let tone: OperationStatus.Tone
        let method: String
        let status: String
        let date: String
        let duration: String?
        let url: String
        let errorDescription: String?
        let webViewBadge: String?
    }
}

#Preview {
    List {
        OperationRow(
            data: .init(
                id: "1",
                tone: .success,
                method: "POST",
                status: "200 OK",
                date: "15:18:20",
                duration: "182.122 sec",
                url: "https://google.com/api/images?id=124",
                errorDescription: nil,
                webViewBadge: nil
            )
        )
        OperationRow(
            data: .init(
                id: "2",
                tone: .failure,
                method: "GET",
                status: "Error -1009",
                date: "15:18:22",
                duration: "12 ms",
                url: "https://olimp.test/payment",
                errorDescription: "-1009: The Internet connection appears to be offline.",
                webViewBadge: "WEB"
            )
        )
        OperationRow(
            data: .init(
                id: "3",
                tone: .neutral,
                method: "POST",
                status: "Redirect → https://pay.test/3ds",
                date: "15:18:25",
                duration: "180 ms",
                url: "https://olimp.test/payment/start",
                errorDescription: nil,
                webViewBadge: "WEB"
            )
        )
    }
}
