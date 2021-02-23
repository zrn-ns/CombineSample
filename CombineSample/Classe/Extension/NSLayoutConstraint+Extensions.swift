//
//  NSLayoutConstraint+Extensions.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/23.
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
