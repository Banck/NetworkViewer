//
//  Request.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public extension NetworkViewer {

    struct Request: Codable {

        public let url: String
        public let method: String
        public let headers: [String: String]
        public let body: Data?

        public init(url: String, method: String, headers: [String: String], body: Data?) {
            self.url = url
            self.method = method
            self.headers = headers
            self.body = body
        }

        public init(_ urlRequest: URLRequest) {
            url = urlRequest.url?.absoluteString ?? "-"
            method = urlRequest.httpMethod ?? "-"
            headers = urlRequest.allHTTPHeaderFields ?? [:]
            body = urlRequest.httpBody
        }
    }
}

public extension NetworkViewer.Request {

    var cURL: String {
#if swift(>=5.0)
        var baseCommand = #"curl "\#(url)""#
#else
        var baseCommand = "curl \"\(url)\""
#endif

        if method == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        for (key, value) in headers where key != "Cookie" {
            command.append("-H '\(key): \(value)'")
        }

        if let data = body, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }
}
