//
//  Operation.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public extension NetworkViewer {
    
    struct Operation {

        let request: Request
        let response: Response?
        let error: CustomError?
        let startAt: TimeInterval
        let endAt: TimeInterval?

        public init(
            request: Request,
            response: Response?,
            error: CustomError?,
            startAt: TimeInterval,
            endAt: TimeInterval?
        ) {
            self.request = request
            self.response = response
            self.error = error
            self.startAt = startAt
            self.endAt = endAt
        }
    }
}
