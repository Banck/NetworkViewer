//
//  File.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public struct CustomError: Codable {

    public let code: Int
    public let message: String

    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }

    public init(_ error: NSError) {
        self.init(code: error.code, message: error.localizedDescription)
    }

    public init(_ error: Error) {
        let nsError = error as NSError
        self.init(nsError)
    }
}
