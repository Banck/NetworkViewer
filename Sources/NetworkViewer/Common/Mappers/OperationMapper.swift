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
    private static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
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
        let statusCode = HTTPStatusCode(rawValue: operation.response?.statusCode ?? 0)
        let startDate = Date(timeIntervalSince1970: operation.startAt)
        var status = "Unknown"
        if let statusCode {
            status = "\(statusCode.rawValue) " + statusCode.description
        }
        var duration: String?
        if let endAt = operation.endAt {
            let endDate = Date(timeIntervalSince1970: endAt)
            let timeInterval = endDate.timeIntervalSince(startDate)
            if timeInterval > 60 {
                numberFormatter.positiveSuffix = " min"
                numberFormatter.maximumFractionDigits = 2
                duration = numberFormatter.string(for: timeInterval / 60)
            }
            if timeInterval > 1 {
                numberFormatter.positiveSuffix = " sec"
                numberFormatter.maximumFractionDigits = 2
                duration = numberFormatter.string(for: timeInterval)
            } else {
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.positiveSuffix = " ms"
                duration = numberFormatter.string(for: timeInterval * 1000)
            }
        }
        let startTime = dateFormatter.string(from: Date(timeIntervalSince1970: operation.startAt))
        var endTime: String? = nil
        if let endAt = operation.endAt {
            endTime = dateFormatter.string(from: Date(timeIntervalSince1970: endAt))
        }
        let json: String =
        """
        {
            "url": "\(operation.request.url)",
            "method": "\(operation.request.method)",
            "status": "\(status)",
            "start_at": "\(startTime) UTC",
            "end_at": "\(endTime != nil ? (endTime! + " UTC") : "null")",
            "duration": "\(duration ?? "null")",
            "request": {
                "headers": \(operation.request.headers.getJsonString() ?? "null"),
                "body": \(operation.request.body?.jsonObject?.getJsonString() ?? "null")
            },
            "response": {
                "headers": \(operation.response?.headers.getJsonString() ?? "null"),
                "body": \(operation.responseData.jsonObject?.getJsonString() ?? "null")
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
