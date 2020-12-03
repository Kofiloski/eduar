//
//  ARController.swift
//  EduAR
//
//  Created by Kristijan Kofiloski on 5/22/19.
//

import UIKit
import ARKit
import SceneKit

class ARController: UIViewController {
    
    @IBOutlet weak var selectObjectButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    private lazy var config: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        return config
    }()
    
    private var computerParts: [String] = []
    private var selectedComputerPart = ""
    
    var event: Subject = .computerParts
    
    private var coordx: Float = 0.0
    private var coordy: Float = 0.0
    private var coordz: Float = 0.0
    private var photoNode: SCNNode = SCNNode(geometry: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(config)
        if event == .computerParts {
            fillComputerPartsList()
            addGestures()
            selectObjectButton.isHidden = false
        } else if event == .nature {
            placeNatureObjectsAroundUser()
            selectObjectButton.isHidden = true
        }
    }
    
    private func retrieveURLFromAssets() -> [URL]? {
        var assetsBaseURL = Bundle.main.bundleURL
        if event == .computerParts {
            assetsBaseURL = assetsBaseURL.appendingPathComponent("ComputerParts.scnassets")
        } else if event == .nature {
            assetsBaseURL = assetsBaseURL.appendingPathComponent("NatureObjects.scnassets")
        }
        
        return try? FileManager.default.contentsOfDirectory(at: assetsBaseURL, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: [.skipsHiddenFiles]).filter({ $0.lastPathComponent.hasSuffix(".scn") })
    }
    
    /// Adds ARScene to the sceneView
    /// - Parameters:
    ///   - scene: SCNScene object that you want to be added to the sceneView.
    ///   - childNodeName: Name of the .scn object
    ///   - position: SCNVector3 object for positioning the scene(object) in the sceneView(world).
    ///
    /// POSITION DESCRIPTIONS:
    /// - X is left and right (- for left + for right). ex: 5 is 5 points to the right of the user.
    /// - Y is up or down from user perspective. I place everything -2 points meaning down otherwise objects seem like floating.
    /// - Z is towards(behind) or in-front of user. ex: -5 is in-front of user.
    private func addARScene(_ scene: SCNScene, childNodeName: String ,at position: SCNVector3) {
        guard let node = (scene.rootNode.childNode(withName: childNodeName, recursively: false)) else {
            return
        }
        
        node.position = position
        
        sceneView.scene.rootNode.addChildNode(node)
        photoNode = node
    }
    
    @IBAction func showParts() {
        showComputerPartsList()
    }
    
    @IBAction func clearAll() {
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if computerParts.contains(node.name ?? "") {
                node.removeFromParentNode()
            }
        }
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
    
    deinit {
        print("DEINIT ARController")
    }
}

// MARK: AR Delegate

extension ARController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
}

// MARK: ComputerParts handling

extension ARController {
    private func fillComputerPartsList() {
        guard let urls = retrieveURLFromAssets() else {
            print("Could not retrieve UR from assets.")
            return
        }
        
        for url in urls {
            computerParts.append(url.lastPathComponent.replacingOccurrences(of: ".scn", with: ""))
        }
    }
    
    private func showComputerPartsList() {
        let alertController = UIAlertController(title: "Parts", message: "Select part that you want to add", preferredStyle: .actionSheet)
        
        for partName in computerParts {
            let alertAction = UIAlertAction(title: partName, style: .default) { _ in
                self.selectedComputerPart = partName
            }
            
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: Gestures
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinched(sender:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotated(sender:)))
        sceneView.addGestureRecognizer(rotateGesture)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(sender:)))
        sceneView.addGestureRecognizer(dragGesture)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            print("Touched on the plane")
            guard let transformMatrix = hitTest.first?.worldTransform,
                  let scene = SCNScene(named: "ComputerParts.scnassets/\(selectedComputerPart).scn") else {
                return
            }
            
            let vector = SCNVector3(transformMatrix.columns.3.x, transformMatrix.columns.3.y, transformMatrix.columns.3.z)
            addARScene(scene, childNodeName: selectedComputerPart, at: vector)
        } else {
            print("Not a plane")
        }
    }
    
    @objc func pinched(sender: UIPinchGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation)
        if !hitTest.isEmpty {
            let node = hitTest.filter({$0.node.name != "FloorNode"}).first?.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node?.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func rotated(sender: UIRotationGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation)
        if !hitTest.isEmpty {
            let node = hitTest.filter({ $0.node.name != "FloorNode" }).first?.node
            if sender.state == .began || sender.state == .changed {
                node?.eulerAngles = SCNVector3(CGFloat((node?.eulerAngles.x)!),sender.rotation,CGFloat((node?.eulerAngles.z)!))
            }
        }
    }
    
    @objc func drag(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let location = sender.location(in: sceneView)
            guard let hitNodeResult = sceneView.hitTest(location).first else { return }
            coordx = hitNodeResult.worldCoordinates.x
            coordy = hitNodeResult.worldCoordinates.y
            coordz = hitNodeResult.worldCoordinates.z
        case .changed:
            // when you start to pan in screen with your finger
            // hittest gives new coordinates of touched location in sceneView
            // coord-pcoord gives distance to move or distance paned in sceneView
            let hitNode = sceneView.hitTest(sender.location(in: sceneView))
            if let hitNodeCoordx = hitNode.first?.worldCoordinates.x,
               let hitNodeCoordy = hitNode.first?.worldCoordinates.y,
               let hitNodeCoordz = hitNode.first?.worldCoordinates.z {
                let action = SCNAction.moveBy(x: CGFloat(hitNodeCoordx - coordx),
                                              y: CGFloat(hitNodeCoordy - coordy),
                                              z: CGFloat(hitNodeCoordz - coordz),
                                              duration: 0.0)
                photoNode.runAction(action)
                
                coordx = hitNodeCoordx
                coordy = hitNodeCoordy
                coordz = hitNodeCoordz
            }
            
            sender.setTranslation(.zero, in: sceneView)
        case .ended:
            coordx = 0.0
            coordy = 0.0
            coordz = 0.0
        default:
            break
        }
    }
}

// MARK: Nature handling

extension ARController {
    private func placeNatureObjectsAroundUser() {
        guard let natureObjectsURLs = retrieveURLFromAssets() else {
            print("Could not retrieve URLs from assets.")
            return
        }
        
        for url in natureObjectsURLs {
            guard let scene = try? SCNScene(url: url) else {
                print("Failed to create scene for url: \(url).")
                return
            }
            
            addARScene(scene, childNodeName: url.lastPathComponent.replacingOccurrences(of: ".scn", with: ""), at: SCNVector3(Int.random(in: -10...10), -2, Int.random(in: -10...10)))
        }
    }
}
