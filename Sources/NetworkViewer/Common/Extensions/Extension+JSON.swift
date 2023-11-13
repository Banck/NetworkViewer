//
//  Extension+JSON.swift
//  
//
//  Created by Sakhabaev Egor on 13.11.2023.
//

import Foundation

extension Data {

    func decode<T: Decodable>(as type: T.Type) -> T? {
        do {
            let obj = try JSONDecoder().decode(T.self, from: self)
            return obj
        } catch {
            #if DEBUG
            print(error)
            #endif

            return nil
        }
    }

    var jsonObject: [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: [.mutableContainers]) as? [String: Any]
        } catch {
            #if DEBUG
            print(error)
            #endif

            return nil
        }
    }
}

extension Dictionary {

    func getJsonString(encoding: String.Encoding = .utf8) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
        else { return nil }
        return String(data: jsonData, encoding: encoding)
    }
}
