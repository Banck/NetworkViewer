//
//  FavoriteService.swift
//
//
//  Created by Sakhabaev Egor on 12.11.2023.
//

import Foundation

class FavoriteService: FavoriteServiceProtocol {

    private let storageKey = "favorite_service_favorites"
    private var favorites: [String]

    init() {
        self.favorites = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    func isFavorite(_ value: String) -> Bool {
        favorites.contains(value)
    }

    func toggleFavorite(for value: String) {
        if isFavorite(value) {
            favorites.removeAll { $0 == value }
        } else {
            favorites.append(value)
        }
        UserDefaults.standard.setValue(favorites, forKey: storageKey)
    }
}
