//
//  Response.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public struct Response: Codable {

    public let statusCode: Int
    public let headers: [Header]

    public init(statusCode: Int, headers: [Header]) {
        self.statusCode = statusCode
        self.headers = headers
    }

    public init?(_ response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
            headers = httpResponse.allHeaderFields.map {
                Header(
                    key: $0.key as? String ?? "Unknown Key",
                    value: $0.value as? String ?? "Unknown Value"
                )
            }
        } else {
            statusCode = 200
            headers = [
                Header(key: "Content-Length", value: "\(response.expectedContentLength)"),
                Header(key: "Content-Type", value: response.mimeType ?? "plain/text")
            ]
        }
    }
}
