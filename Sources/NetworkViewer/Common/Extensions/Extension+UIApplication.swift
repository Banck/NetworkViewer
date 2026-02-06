//
//  public extension + UIWindow.swift
//
//  Created by Artem Balashov on 12/03/2019.
//  Copyright © 2019 Egor Sakhabaev. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    class func topViewController(
        controller: UIViewController? = nil
    ) -> UIViewController? {
        var controller = controller
        if controller == nil {
            let windows = UIApplication.shared.windows
            let window = windows.first { $0.isKeyWindow } ?? windows.first
            controller = window?.rootViewController
        }
        if
            let navigationController = controller as? UINavigationController,
            let visibleController = navigationController.visibleViewController
        {
            return topViewController(controller: visibleController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func endEditing() {
        shared.windows.first?.endEditing(true)
    }
}
