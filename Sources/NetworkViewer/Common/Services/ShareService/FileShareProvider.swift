//
//  FileShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import Foundation
import UIKit

final class FileShareProvider: ShareProvider {

    var displayName: String { "file" }
    var icon: UIImage? = UIImage(systemName: "arrow.down.doc")

    func shareData(for operations: [NetworkViewer.Operation]) -> ShareResult? {
        let json = mapToJSON(for: operations)
        
        if let fileURL = createTempFile(with: json) {
            return .url(fileURL)
        }
        return nil
    }

    private func createTempFile(with content: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("operations.json")

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}

