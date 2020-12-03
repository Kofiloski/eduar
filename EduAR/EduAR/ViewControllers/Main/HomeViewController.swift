//
//  HomeViewController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 8/21/19.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBAction func findMax() {
        present(MasterViewController.instantiate(storyboardName: "Main"), animated: true)
    }
    
    @IBAction func seeRobot() {
        present(ARQuickLookController(), animated: true)
    }
    
    @IBAction func buildSetup() {
        let arController = ARController.instantiate(storyboardName: "AugmentedReality")
        arController.event = .computerParts
        present(arController, animated: true)
    }
    
    @IBAction func treesAreLife() {
        let arController = ARController.instantiate(storyboardName: "AugmentedReality")
        arController.event = .nature
        present(arController, animated: true)
    }
}
