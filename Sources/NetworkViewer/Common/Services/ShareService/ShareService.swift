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
    
    func shareData(for operations: [NetworkViewer.Operation]) -> ShareService.Result?
}

public class ShareService {
    public enum Result: Hashable, Identifiable {
        public var id: Self { self }
        case url(URL)
        case text(String)
        
        func get() -> Any {
            switch self {
            case .url(let url):
                return url
            case .text(let text):
                return text
            }
        }
    }
    
    private var providers: [ShareProvider]
    
    init(providers: [ShareProvider] = []) {
        self.providers = providers
    }
    
    func addProvider(_ provider: ShareProvider) {
        providers.append(provider)
    }
    
    func availableProviders() -> [ShareProvider] {
        return providers
    }
}
