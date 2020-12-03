//
//  ViewController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 5/21/19.
//

import UIKit
import QuickLook

class ARQuickLookController: QLPreviewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
    
    ///   Lazy variable for obtaining NSURL for a resource.
    /// - Parameter name: String of the full name with extension of the resource you are looking for.
    /// - Returns
    ///   NSURL for the passed in name parameter, if available.
    var NSURLForResourceWithName = { (name: String) -> NSURL in
        let nameComponents = name.components(separatedBy: ".")
        guard let resourceName = nameComponents.first,
            let resourceType = nameComponents.last,
            let path = Bundle.main.path(forResource: resourceName, ofType: resourceType) else {
                print("No resource found for \(name)")
                return NSURL()
        }
        return NSURL(fileURLWithPath: path)
    }
    
    deinit {
        print("DEINIT ARQuickLookController")
    }
}

extension ARQuickLookController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return NSURLForResourceWithName("toy_robot_vintage.usdz")
    }
}


