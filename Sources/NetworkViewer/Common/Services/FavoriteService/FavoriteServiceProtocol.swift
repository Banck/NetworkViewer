//
//  FavoriteServiceProtocol.swift
//  
//
//  Created by Sakhabaev Egor on 12.11.2023.
//

import Foundation

protocol FavoriteServiceProtocol {

    func isFavorite(_ value: String) -> Bool
    func toggleFavorite(for value: String)
}
