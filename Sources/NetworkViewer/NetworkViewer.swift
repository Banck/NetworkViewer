//
//  NetworkViewer.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import UIKit
import SwiftUI

public class NetworkViewer {

    public private(set) static var operations: [NetworkViewer.Operation] = [] {
        didSet {
            domainListInput?.updateOperations(operations)
            NotificationCenter.default.post(name: operationsDidChange, object: nil)
        }
    }
    public static var invokeByShake: Bool = false
    /// Posted on the thread that changed `operations`.
    static let operationsDidChange = Notification.Name("NetworkViewer.operationsDidChange")
    static let favoriteService: FavoriteServiceProtocol = FavoriteService()
    private static var domainListInput: DomainListModuleInput?

    public static func addOperation(_ operation: NetworkViewer.Operation) {
        operations.append(operation)
    }

    /// Replaces the operation with the same `id` (keeping its position) or appends it if there is none.
    /// Use it to complete an operation that was added before its response arrived.
    public static func updateOperation(_ operation: NetworkViewer.Operation) {
        if let index = operations.firstIndex(where: { $0.id == operation.id }) {
            operations[index] = operation
        } else {
            operations.append(operation)
        }
    }

    /**
     Present screen with network operations.
     - parameter operations: you can pass specify array of operations otherwise NetworkViewer.operations will be used.
     **/
    public static func show(_ shareProviders: [ShareProvider]? = nil) {
        guard let topController = UIApplication.topViewController() else { return }
        var providers: [ShareProvider] = [
            CurlShareProvider(),
            TextShareProvider(),
            FileShareProvider(),
            HARShareProvider()
        ]
        if let shareProviders {
            providers.append(contentsOf: shareProviders)
        }
        let shareService = ShareService(providers: providers)
        let module = DomainListConfigurator.createModule(operations: operations, shareService: shareService)
        domainListInput = module.input
        topController.present(UIHostingController(rootView: module.view), animated: true)
    }

    static func deleteAllOperations() {
        operations.removeAll()
    }
    /// `domainKey` keeps WebView operations of a host apart from its native ones.
    static func deleteAllOperations(forDomainKey domainKey: String) {
        operations.removeAll { $0.domainKey == domainKey }
    }
}

// MARK: - Shake invokation
extension UIWindow {

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard NetworkViewer.invokeByShake,  motion == .motionShake else { return }
        let topController = UIApplication.topViewController()
        guard topController?.classForCoder.description().contains("NetworkViewer") == false else { return }
        NetworkViewer.show()
    }
}
