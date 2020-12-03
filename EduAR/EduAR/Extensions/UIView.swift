//
//  UIView.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/26/19.
//

import UIKit

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        subviews.forEach { recursiveSubviews.append(contentsOf: $0.recursiveSubviews()) }
        return recursiveSubviews
    }
}
