//
//  NetworkViewer.swift
//  
//
//  Created by Sakhabaev Egor on 10.11.2023.
//

import UIKit
import SwiftUI

public class NetworkViewer {

    public private(set) static var operations: [Operation] = []

    public static func addOperation(_ operation: Operation) {
        operations.append(operation)
    }

    /**
     Present screen with network operations.
     - parameter operations: you can pass specify array of operations otherwise NetworkViewer.operations will be used.
     **/
    public static func show(operations: [Operation] = operations) {
        guard let topController = UIApplication.topViewController() else { return }
        let operationsByDomain = Dictionary(grouping: operations) { URL(string: $0.request.url)?.host ?? $0.request.url }
        let domainList: [DomainData] = operationsByDomain.map { (domain: String, operations: [Operation]) in
                .init(
                    domain: domain,
                    operationsCount: operations.count,
                    isPinned: false
                )
        }
        let module = DomainListConfigurator.createModule(domainList: domainList)
        topController.present(UIHostingController(rootView: module.view), animated: true)
    }
}
