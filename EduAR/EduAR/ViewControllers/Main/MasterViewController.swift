//
//  MasterViewController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 8/24/19.
//

import UIKit
import MapKit

class MasterViewController: UIViewController {
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    private var controller: UIViewController!
    
    private var mapController: MapController = {
        return MapController.instantiate(storyboardName: "Map")
    }()
    
    private var arController: ARDirectionsController = {
        return ARDirectionsController.instantiate(storyboardName: "AugmentedReality")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelector(forState: .map)
        changeViewController(forState: .map)
        mapController.delegate = arController
    }
    
    private func updateSelector(forState state: SceneState) {
        mapButton.backgroundColor = state == .map ? .white : .lightGray
        arButton.backgroundColor = state == .map ? .lightGray : .white
        mapButton.titleLabel?.textColor = state == .map ? .black : .white
        arButton.titleLabel?.textColor = state == .map ? .white : .black
    }
    
    private func changeViewController(forState state: SceneState) {
        controller = state == .map ? mapController : arController
        addChild(controller)
        contentView.addSubview(controller.view)
        controller.view.frame = contentView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func showMap() {
        updateSelector(forState: .map)
        changeViewController(forState: .map)
    }
    
    @IBAction func showAR() {
        updateSelector(forState: .ar)
        changeViewController(forState: .ar)
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
}
