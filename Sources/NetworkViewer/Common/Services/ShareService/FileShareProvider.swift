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
    var icon: UIImage? = UIImage(systemName: "arrow.down.doc.fill")

    func shareData(for operations: [NetworkViewer.Operation]) -> ShareService.Result? {
        let combinedContent = operations.map { OperationMapper.jsonFrom($0) }.joined(separator: "\n\n")
        if let fileURL = createTempFile(with: combinedContent) {
            return .url(fileURL)
        }
        return nil
    }

    private func createTempFile(with content: String) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("operations.txt")

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}

