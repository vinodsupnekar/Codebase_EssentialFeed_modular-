//
//  UITableView+Dequeing.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 24/04/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
