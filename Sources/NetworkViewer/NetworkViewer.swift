//
//  NetworkViewer.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import UIKit
import SwiftUI
import Combine

public class NetworkViewer {

    /// Changed only on the main thread; read it on the main thread.
    public private(set) static var operations: [NetworkViewer.Operation] = [] {
        didSet {
            domainListInput?.updateOperations(operations)
            operationsDidChange.send()
        }
    }
    public static var invokeByShake: Bool = false
    /// Fires on the main thread after `operations` changed.
    static let operationsDidChange = PassthroughSubject<Void, Never>()
    static let favoriteService: FavoriteServiceProtocol = FavoriteService()
    private static var domainListInput: DomainListModuleInput?

    /// Safe to call from any thread: the change is applied asynchronously on the main queue, in call order.
    public static func addOperation(_ operation: NetworkViewer.Operation) {
        onMain { operations.append(operation) }
    }

    /// Replaces the operation with the same `id`, keeping its position; does nothing if there is none
    /// (for example, it was deleted). Use it to complete an operation added before its response arrived.
    /// Safe to call from any thread: the change is applied asynchronously on the main queue, in call order.
    public static func updateOperation(_ operation: NetworkViewer.Operation) {
        onMain {
            guard let index = operations.firstIndex(where: { $0.id == operation.id }) else { return }
            operations[index] = operation
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
        onMain { operations.removeAll() }
    }
    /// `domainKey` keeps WebView operations of a host apart from its native ones.
    static func deleteAllOperations(forDomainKey domainKey: String) {
        onMain { operations.removeAll { $0.domainKey == domainKey } }
    }

    /// Always queued, even from the main thread: the main queue keeps changes from different threads in call order.
    private static func onMain(_ change: @escaping () -> Void) {
        DispatchQueue.main.async(execute: change)
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
