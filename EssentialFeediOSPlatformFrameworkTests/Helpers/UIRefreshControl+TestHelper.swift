//
//  UIRefreshControl+TestHelper.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 10/04/23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
