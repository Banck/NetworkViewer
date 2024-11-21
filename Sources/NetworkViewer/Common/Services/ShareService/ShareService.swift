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

extension ShareProvider {
    func mapToJSON(for operations: [NetworkViewer.Operation]) -> String {
        let json: String
        if operations.count == 1 {
            json = OperationMapper.jsonFrom(operations[0])
        } else {
            let operationsArray = operations.map { OperationMapper.jsonFrom($0) }
            json = """
            {
              "operations": [
                \(operationsArray.joined(separator: ",\n"))
              ]
            }
            """
        }
        return json
    }
}

public class ShareService: ObservableObject {
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
    static let defaultValue: ShareService = ShareService(providers: [CurlShareProvider() ,TextShareProvider(), FileShareProvider()])
}

extension EnvironmentValues {
    var shareService: ShareService {
        get { self[ShareServiceEnvironmentKey.self] }
        set { self[ShareServiceEnvironmentKey.self] = newValue }
    }
}
