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

    var jsonObject: Any? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: [.mutableContainers])
        } catch {
            #if DEBUG
            print(error)
            #endif

            return nil
        }
    }
}

func getJsonString(jsonObject: Any?, encoding: String.Encoding = .utf8) -> String? {
    guard let jsonObject else { return nil }
    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
    else { return nil }
    return String(data: jsonData, encoding: encoding)
}
