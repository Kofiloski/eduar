//
//  UIViewController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 2/7/20.
//

import UIKit

extension UIViewController {

    /// Instantiate a UIViewController from storyboard, NOTE: storyboard name should be the same as class name.
    /// - Parameter storyboardName: Which storyboard is the UIViewController located in.
    /// - Returns
    ///   instance of the UIViewController it is called upon.
    static func instantiate(storyboardName: String) -> Self {
        UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}
