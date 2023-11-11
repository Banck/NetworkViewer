//
//  NetworkViewer.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import UIKit
import SwiftUI

public class NetworkViewer {

    public private(set) static var operations: [NetworkViewer.Operation] = []
    public static var invokeByShake: Bool = false

    public static func addOperation(_ operation: NetworkViewer.Operation) {
        operations.append(operation)
    }

    /**
     Present screen with network operations.
     - parameter operations: you can pass specify array of operations otherwise NetworkViewer.operations will be used.
     **/
    public static func show(operations: [Operation] = operations) {
        guard let topController = UIApplication.topViewController() else { return }
        let module = DomainListConfigurator.createModule(operations: operations)
        topController.present(UIHostingController(rootView: module.view), animated: true)
    }
}

// MARK: - Shake invokation
extension UIWindow {

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard NetworkViewer.invokeByShake,  motion == .motionShake else { return }
        NetworkViewer.show()
    }
}
