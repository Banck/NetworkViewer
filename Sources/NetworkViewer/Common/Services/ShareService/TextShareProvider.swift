//
//  TextShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import Foundation
import UIKit

final class TextShareProvider: ShareProvider {
    var displayName: String = "Text"
    var icon: UIImage? = UIImage(systemName: "doc.on.doc")
    
    private let handlers: [ShareDataHandler] = [
        OperationsToJsonDataHandler(),
        StringDataHandler()
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
