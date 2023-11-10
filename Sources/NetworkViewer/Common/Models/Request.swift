//
//  Request.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public struct Request: Codable {

    public let url: String
    public let method: String
    public let headers: [Header]
    public let body: Data?

    public init(url: String, method: String, headers: [Header], body: Data?) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    public init(_ urlRequest: URLRequest) {
        url = urlRequest.url?.absoluteString ?? "-"
        method = urlRequest.httpMethod ?? "-"
        headers = urlRequest.allHTTPHeaderFields?.map { Header(key: $0.key, value: $0.value ) } ?? []
        body = urlRequest.httpBody
    }
}
