//
//  UIApplication+Extension.swift
//  VRVideoPlayer
//
//  Created by Jhonny Bill Mena on 7/12/19.
//  Copyright © 2019 com.monteroc. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController = (UIApplication.shared.keyWindow?.rootViewController)!) -> UIViewController {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController!)
        }
        
        if let selected = (base as? UITabBarController)?.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
