//
//  Operation.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public extension NetworkViewer {
    
    public struct Operation {

        let id: String
        let request: Request
        let response: Response?
        let responseData: Data
        let error: CustomError?
        let startAt: TimeInterval
        let endAt: TimeInterval?
        let isFromWebView: Bool

        public init(
            id: String,
            request: Request,
            response: Response?,
            responseData: Data,
            error: CustomError?,
            startAt: TimeInterval,
            endAt: TimeInterval?,
            isFromWebView: Bool = false
        ) {
            self.id = id
            self.request = request
            self.response = response
            self.responseData = responseData
            self.error = error
            self.startAt = startAt
            self.endAt = endAt
            self.isFromWebView = isFromWebView
        }
    }
}
