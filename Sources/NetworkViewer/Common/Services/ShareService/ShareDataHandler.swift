//
//  ShareDataHandler.swift
//  NetworkViewer
//
//  Created by Mакс T on 22.11.2024.
//

import Foundation

protocol ShareDataHandler {
    func canHandle(_ data: Any) -> Bool
    func process(_ data: Any) -> String?
}

extension ShareDataHandler {

    func mapToJSON(for operations: [NetworkViewer.Operation]) -> String {
        let json: String
        if operations.count == 1 {
            json = OperationMapper.jsonFrom(operations[0])
        } else {
            let operationsArray = operations.map { OperationMapper.jsonFrom($0) }
            json = """
            {
              "operations": [
                \(operationsArray.joined(separator: ",\n"))
              ]
            }
            """
        }
        return json
    }
}


final class OperationsToCurlDataHandler: ShareDataHandler {
    func canHandle(_ data: Any) -> Bool {
        data is [NetworkViewer.Operation]
    }
    
    func process(_ data: Any) -> String? {
        guard let operations = data as? [NetworkViewer.Operation] else { return nil }
        let result = operations.map { $0.request.cURL }.joined(separator: "\n\n")
        return result
    }
}

final class OperationsToJsonDataHandler: ShareDataHandler {
    func canHandle(_ data: Any) -> Bool {
        data is [NetworkViewer.Operation]
    }
    
    func process(_ data: Any) -> String? {
        guard let operations = data as? [NetworkViewer.Operation] else { return nil }
        let json = mapToJSON(for: operations)
        return json
    }
}

final class StringDataHandler: ShareDataHandler {
    func canHandle(_ data: Any) -> Bool {
        data is String
    }
    
    func process(_ data: Any) -> String? {
        guard let text = data as? String else { return nil }
        return text
    }
}

final class OperationsToHARDataHandler: ShareDataHandler {
    func canHandle(_ data: Any) -> Bool {
        data is [NetworkViewer.Operation]
    }
    
    func process(_ data: Any) -> String? {
        guard let operations = data as? [NetworkViewer.Operation] else { return nil }
        let json = mapToHAR(for: operations)
        return json
    }
}

extension OperationsToHARDataHandler {

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

