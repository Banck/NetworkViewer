//
//  TextShareProvider.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import Foundation
import UIKit

final class TextShareProvider: ShareProvider {
    var displayName: String = "text"
    var icon: UIImage? = UIImage(systemName: "doc.on.doc")

    func shareData(for operations: [NetworkViewer.Operation]) -> ShareService.Result? {
        let jsons = operations.map { OperationMapper.jsonFrom($0) }.joined(separator: "\n\n")
        return .text(jsons)
    }
}
