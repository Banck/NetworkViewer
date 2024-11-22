//
//  HARShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 21.11.2024.
//

import Foundation
import UIKit

final class HARShareProvider: ShareProvider {

    var displayName: String { "har file" }
    var icon: UIImage? = UIImage(systemName: "doc.text")

    func shareData(for operations: [NetworkViewer.Operation]) async -> ShareResult? {
        return await Task.detached {
            let harContent = self.mapToHAR(for: operations)
            if let fileURL = self.createTempFile(with: harContent, filename: "operations.har") {
                return .url(fileURL)
            }
            return nil
        }.value
    }
}

extension HARShareProvider {

    private func mapToHAR(for operations: [NetworkViewer.Operation]) -> String {
        let entries = operations.map { createEntry(from: $0) }

        let har: [String: Any] = [
            "log": [
                "version": "1.2",
                "creator": [
                    "name": "NetworkViewer",
                    "version": "1.0"
                ],
                "entries": entries
            ]
        ]

        return serializeJSON(har)
    }

    private func createEntry(from operation: NetworkViewer.Operation) -> [String: Any] {
        let requestHeaders = operation.request.headers.map { ["name": $0.key, "value": $0.value] }
        let responseHeaders = operation.response?.headers.map { ["name": $0.key, "value": $0.value] } ?? []

        let requestBody = operation.request.body?.base64EncodedString() ?? ""
        let responseBody = prettifyJSON(from: operation.responseData) ?? operation.responseData.base64EncodedString()

        let statusCode = operation.response?.statusCode ?? operation.error?.code ?? 0
        let statusText = HTTPStatusCode(rawValue: statusCode)?.description ?? "Unknown"

        let timings = calculateTimings(startAt: operation.startAt, endAt: operation.endAt)

        var entry: [String: Any] = [
            "startedDateTime": ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: operation.startAt)),
            "time": timings.total,
            "request": [
                "method": operation.request.method,
                "url": operation.request.url,
                "httpVersion": "HTTP/1.1",
                "headers": requestHeaders,
                "postData": [
                    "mimeType": "application/json",
                    "text": requestBody
                ],
                "headersSize": -1,
                "bodySize": requestBody.count
            ],
            "response": [
                "status": statusCode,
                "statusText": statusText,
                "httpVersion": "HTTP/1.1",
                "headers": responseHeaders,
                "content": [
                    "size": responseBody.count,
                    "mimeType": "application/json",
                    "text": responseBody
                ],
                "headersSize": -1,
                "bodySize": responseBody.count
            ],
            "cache": [:],
            "timings": timings.details
        ]

        if let error = operation.error {
            entry["response"] = [
                "status": error.code,
                "statusText": error.message,
                "headers": [],
                "content": [
                    "size": 0,
                    "mimeType": "",
                    "text": ""
                ],
                "headersSize": -1,
                "bodySize": 0
            ]
        }

        return entry
    }

    private func calculateTimings(startAt: TimeInterval, endAt: TimeInterval?) -> (total: Double, details: [String: Double]) {
        let total = ((endAt ?? startAt) - startAt) * 1000
        let details: [String: Double] = [
            "send": 0,
            "wait": total,
            "receive": 0
        ]
        return (total, details)
    }

    private func serializeJSON(_ object: Any) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }

    private func prettifyJSON(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
