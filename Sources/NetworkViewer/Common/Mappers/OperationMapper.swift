//
//  OperationMapper.swift
//
//
//  Created by Ivan Ipatov on 16.12.2023.
//

import Foundation

struct OperationMapper {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    private static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.isAdaptive = false
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter
    }()

    static func jsonFrom(_ operation: NetworkViewer.Operation) -> String {
        let operationStatus = OperationStatus(operation)
        let status = operationStatus.text
        let duration = operationStatus.duration
        let startTime = dateFormatter.string(from: Date(timeIntervalSince1970: operation.startAt))
        var endTime: String? = nil
        if let endAt = operation.endAt {
            endTime = dateFormatter.string(from: Date(timeIntervalSince1970: endAt))
        }
        let json: String =
        """
        {
            "url": "\(operation.request.url)",
            "method": "\(operation.request.exportMethod)",
            "status": "\(status)",
            "start_at": "\(startTime) UTC",
            "end_at": "\(endTime != nil ? (endTime! + " UTC") : "null")",
            "duration": "\(duration ?? "null")",
            "request": {
                "headers": \(getJsonString(jsonObject: operation.request.headers) ?? "null"),
                "body": \(getJsonString(jsonObject: operation.request.body?.jsonObject) ?? "null")
            },
            "response": {
                "headers": \(getJsonString(jsonObject: operation.response?.headers) ?? "null"),
                "body": \(getJsonString(jsonObject: operation.responseData.jsonObject) ?? "null")
            },
            "error": {
                "code": "\(operation.error?.code.description ?? "null")",
                "message": "\(operation.error?.message ?? "null")"
            }
        }
        """
        return json
    }
}

struct OperationJson {
    let url: String
    let method: String
    let startAt: String
    let endAt: String
}
