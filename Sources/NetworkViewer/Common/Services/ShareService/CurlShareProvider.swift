//
//  CurlShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import Foundation
import UIKit

final class CurlShareProvider: ShareProvider {
    var displayName: String = "cURL"
    var icon: UIImage? = UIImage(systemName: "doc.badge.arrow.up")
    
    private let handlers: [ShareDataHandler] = [
        OperationsToCurlDataHandler(),
    ]

    func isAvailable(for data: Any) -> Bool {
        handlers.contains { $0.canHandle(data) }
    }
    
    func shareData(for data: Any) async -> Any? {
        guard let handler = handlers.first(where: { $0.canHandle(data) }) else { return nil }
        
        return await Task.detached {
            guard let result = handler.process(data) else { return nil }
            return result
        }.value
    }
}
