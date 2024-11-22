//
//  HARShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 21.11.2024.
//

import Foundation
import UIKit

final class HARShareProvider: ShareProvider {

    var displayName: String { ".har" }
    var icon: UIImage? = UIImage(systemName: "doc.text")
    
    private let handlers: [ShareDataHandler] = [
        OperationsToHARDataHandler()
    ]
    
    func isAvailable(for data: Any) -> Bool {
        handlers.contains { $0.canHandle(data) }
    }
    
    func shareData(for data: Any) async -> Any? {
        guard let handler = handlers.first(where: { $0.canHandle(data) }) else { return nil }
        
        return await Task.detached {
            guard
                let json = handler.process(data),
                let fileURL = self.createTempFile(with: json, filename: "operations.har")
            else {
                return nil
            }
            return fileURL
        }.value
    }
}
