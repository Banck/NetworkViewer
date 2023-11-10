//
//  Header.swift
//
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import Foundation

public struct Header: Codable {

    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
