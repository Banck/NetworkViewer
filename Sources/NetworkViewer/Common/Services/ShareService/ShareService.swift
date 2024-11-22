//
//  ShareService.swift
//  NetworkViewer
//
//  Created by Mакс T on 19.11.2024.
//

import UIKit
import SwiftUI

public protocol ShareProvider {

    var displayName: String { get }
    var icon: UIImage? { get }
    
    func shareData(for data: Any) async -> Any?
    func isAvailable(for data: Any) -> Bool
}

extension ShareProvider {
    
    func createTempFile(with content: String, filename: String = "operations.json") -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}

public class ShareService: ObservableObject {

    @Published private (set)var providers: [ShareProvider]
    
    init(providers: [ShareProvider] = []) {
        self.providers = providers
    }
    
    func addProvider(_ provider: ShareProvider) {
        providers.append(provider)
    }
    
    func addProviders(_ providers: [ShareProvider]) {
        self.providers.append(contentsOf: providers)
    }
}

private struct ShareServiceEnvironmentKey: EnvironmentKey {

    static let defaultValue: ShareService = ShareService(
        providers: [
            CurlShareProvider(),
            TextShareProvider(),
            FileShareProvider(),
            HARShareProvider()
        ]
    )
}

extension EnvironmentValues {

    var shareService: ShareService {
        get { self[ShareServiceEnvironmentKey.self] }
        set { self[ShareServiceEnvironmentKey.self] = newValue }
    }
}
