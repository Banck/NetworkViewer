//
//  RowIdentifible.swift
//
//  Created by Sakhabaev Egor on 23.10.2023.
//

import Foundation

public protocol RowIdentifible: Identifiable {

    var id: String { get set }
}
