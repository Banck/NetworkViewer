//
//  Operation.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public struct Operation {

    let request: Request
    let response: Response?
    let error: CustomError?

    public init(request: Request, response: Response?, error: CustomError?) {
        self.request = request
        self.response = response
        self.error = error
    }
}
