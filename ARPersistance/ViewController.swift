//
//  ViewController.swift
//  ARPersistance
//
//  Created by Collin Hemeltjen on 10/12/2019.
//  Copyright © 2019 Collin Hemeltjen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var refImage: ARReferenceImage!
	var vase: SCNNode!
//	var light: SCNLight!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

		// Load vase so we won't have to when placing it
		let arScene = SCNScene(named: "art.scnassets/vase/vase.scn")
		vase = arScene!.rootNode.childNode(withName: "box", recursively: false)
//		light = vase.light!
    }

	let ambientLight = SCNLight()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

		refImage = ARReferenceImage.referenceImages(inGroupNamed: "Pictures",
													bundle: nil)!.first

		let config = ARWorldTrackingConfiguration()
		config.detectionImages = [refImage]
		config.maximumNumberOfTrackedImages = 1
		config.isLightEstimationEnabled = true

		let options = [ARSession.RunOptions.removeExistingAnchors,
					   ARSession.RunOptions.resetTracking]

		sceneView.session.run(config, options: ARSession.RunOptions(options))

		ambientLight.type = .ambient
		ambientLight.intensity = 40

		sceneView.scene.rootNode.light = ambientLight
		sceneView.autoenablesDefaultLighting = false
    }

	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
	  guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }

		//2. Get The Ambient Intensity & Colour Temperatures
        let ambientLightEstimate = lightEstimate.ambientIntensity

        let ambientColourTemperature = lightEstimate.ambientColorTemperature

        print(
            """
            Current Light Estimate = \(ambientLightEstimate)
            Current Ambient Light Colour Temperature Estimate = \(ambientColourTemperature)
            """)

        if ambientLightEstimate < 100 { print("Lighting Is Too Dark") }

        //3. Adjust The Scene Lighting
        ambientLight.intensity = ambientLightEstimate
        ambientLight.temperature = ambientColourTemperature
//		light.temperature = ambientColourTemperature
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
	var objects = [SCNNode]()
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		if let validImageAnchor = anchor as? ARImageAnchor {
			return addVaseTo(imageAnchor: validImageAnchor)
		}
		return nil
    }

	func addVaseTo(imageAnchor anchor: ARImageAnchor) -> SCNNode {
		let node = SCNNode()

		objects.append(node)
		// Add a vase to the plane
		vase.position = SCNVector3Zero

		let occlusionPlane = vase.childNode(withName: "occlusion", recursively: false)
		occlusionPlane?.geometry?.materials.first?.colorBufferWriteMask = []
		node.addChildNode(vase)

		return node
	}
}
