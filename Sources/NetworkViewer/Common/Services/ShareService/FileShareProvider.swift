//
//  FileShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import Foundation
import UIKit

final class FileShareProvider: ShareProvider {

    var displayName: String { ".json" }
    var icon: UIImage? = UIImage(systemName: "arrow.down.doc")
    
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
            guard
                let json = handler.process(data),
                let fileURL = self.createTempFile(with: json)
            else {
                return nil
            }
            return fileURL
        }.value
    }
}
