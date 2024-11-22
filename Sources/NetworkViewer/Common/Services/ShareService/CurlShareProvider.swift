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
    
    func shareData(for operations: [NetworkViewer.Operation]) async -> ShareResult? {
        return await Task.detached {
            let curlCommands = operations.map { $0.request.cURL }.joined(separator: "\n\n")
            return .text(curlCommands)
        }.value
    }
}
