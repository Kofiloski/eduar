//
//  ARDirectionsController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 6/26/19.
//

import ARCL
import ARKit
import MapKit
import SceneKit
import UIKit

class ARDirectionsController: UIViewController {
    
    private lazy var addObjectToViewTimer: Timer = {
        let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(2), repeats: true) { [weak self] _ in
            self?.shouldAddObjectsToScene()
        }
        
        return timer
    }()
    
    private var sceneLocationView = SceneLocationView()
    
    private var routes: [MKRoute] = []
    private var addedDirectionsToScene = false
    private var shouldAddDog = false
    private var addedDog = false
    private var didLoadView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        addObjectToViewTimer.fire()
        didLoadView = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    private func shouldAddObjectsToScene() {
        if didLoadView {
            if routes.count > 0 && !addedDirectionsToScene {
                addDirectionsToScene()
            }
            
            if !addedDog && shouldAddDog {
                addDog()
            }
        }
    }
    
    /// Adds the ARKit models to the scene.
    func addDirectionsToScene() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.addDirectionsToScene()
            }
            return
        }
        
        sceneLocationView.addRoutes(routes: routes) { distance in
            let box = SCNBox(width: 1.75, height: 0.5, length: distance, chamferRadius: 0.25)
            box.firstMaterial?.diffuse.contents = UIColor.red
            return box
        }
        
        addedDirectionsToScene = true
    }
    
    /// Adds the Dog object to current scene view.
    ///
    /// POSITION DESCRIPTIONS:
    /// - X is left and right (- for left + for right). ex: 5 is 5 points to the right of the user.
    /// - Y is up or down from user perspective. I place everything -2 points meaning down otherwise objects seem like floating.
    /// - Z is towards(behind) or in-front of user. ex: -5 is in-front of user.
    private func addDog() {
        guard let scene = SCNScene(named:"Animals.scnassets/Dog.scn"),
              let dogNode = (scene.rootNode.childNode(withName: "Dog", recursively: false)) else {
            return
        }
        
        dogNode.position = SCNVector3(2, -3, -5)
        sceneLocationView.scene.rootNode.addChildNode(dogNode)
        addedDog = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
    
    deinit {
        print("DEINIT ARDirectionsController")
    }
}

extension ARDirectionsController: MapControllerDelegate {
    func retrievedRoutes(routes: [MKRoute]) {
        self.routes = routes
    }
    
    func reachedDestination() {
        shouldAddDog = true
    }
}
