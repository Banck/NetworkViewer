//
//  Response.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public extension NetworkViewer {

    struct Response: Codable {

        public let statusCode: Int
        public let headers: [String: String]

        public init(statusCode: Int, headers: [String: String]) {
            self.statusCode = statusCode
            self.headers = headers
        }

        public init?(_ response: URLResponse) {
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
                var headers: [String: String] = [:]
                httpResponse.allHeaderFields.forEach {
                    headers[$0.key as? String ?? "Unknown key"] = $0.value as? String ?? "Unknown value"
                }
                self.headers = headers
            } else {
                statusCode = 200
                headers = [
                    "Content-Length": "\(response.expectedContentLength)",
                    "Content-Type": response.mimeType ?? "plain/text"
                ]
            }
        }
    }
}
