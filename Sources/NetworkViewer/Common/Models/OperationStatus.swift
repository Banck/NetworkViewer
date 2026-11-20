//
//  OperationStatus.swift
//

import Foundation

/// What the UI and exports show as the outcome of an operation.
struct OperationStatus: Equatable {

    enum Tone: Equatable {
        case success
        case failure
        case neutral
    }

    let text: String
    let tone: Tone
    let duration: String?
    /// "<code>: <message>" of the operation error, if any.
    let errorDescription: String?

    init(_ operation: NetworkViewer.Operation) {
        let error = operation.error
        errorDescription = error.map { "\($0.code): \($0.message)" }

        if let redirectURL = operation.redirectURL {
            text = "Redirect → \(redirectURL)"
            tone = .neutral
        } else if let response = operation.response {
            if let statusCode = HTTPStatusCode(rawValue: response.statusCode) {
                text = "\(statusCode.rawValue) \(statusCode.description)"
            } else {
                text = "\(response.statusCode)"
            }
            if error != nil {
                tone = .failure
            } else if (200...299).contains(response.statusCode) {
                tone = .success
            } else if operation.isFromWebView && (300...399).contains(response.statusCode) {
                // WebKit reports e.g. 304 for a page revalidated from cache: not a failure.
                tone = .neutral
            } else {
                tone = .failure
            }
        } else if let error {
            text = "Error \(error.code)"
            tone = .failure
        } else if operation.endAt == nil {
            text = "Pending"
            tone = .neutral
        } else if operation.isFromWebView && !operation.isFromIFrame {
            text = "No response (cache)"
            tone = .neutral
        } else {
            text = "Unknown"
            tone = .failure
        }

        if let endAt = operation.endAt, !operation.isFromIFrame {
            duration = Self.formatDuration(endAt - operation.startAt)
        } else {
            duration = nil
        }
    }

    // Configured once and never mutated: statuses are built both on the main thread and in exports.
    private static let minutesFormatter = makeDurationFormatter(fractionDigits: 2, suffix: " min")
    private static let secondsFormatter = makeDurationFormatter(fractionDigits: 2, suffix: " sec")
    private static let millisecondsFormatter = makeDurationFormatter(fractionDigits: 0, suffix: " ms")

    private static func makeDurationFormatter(fractionDigits: Int, suffix: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = fractionDigits
        formatter.positiveSuffix = suffix
        return formatter
    }

    private static func formatDuration(_ timeInterval: TimeInterval) -> String? {
        if timeInterval > 60 {
            return minutesFormatter.string(for: timeInterval / 60)
        } else if timeInterval > 1 {
            return secondsFormatter.string(for: timeInterval)
        } else {
            return millisecondsFormatter.string(for: timeInterval * 1000)
        }
    }
}

extension NetworkViewer.Operation {

    /// Marks WebView operations in the UI; `nil` for native operations.
    var webViewBadge: String? {
        guard isFromWebView else { return nil }
        return isFromIFrame ? "WEB · iframe" : "WEB"
    }
}
