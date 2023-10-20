//
//  ARView.swift
//  ARAPIStarter
//
//  Created by Nien Lam on 10/19/23.
//  Copyright © 2023 Line Break, LLC. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    
    func makeUIView(context: Context) -> SimpleARView {
        SimpleARView(frame: .zero, viewModel: viewModel)
    }
    
    func updateUIView(_ arView: SimpleARView, context: Context) {
        arView.updateWithSliderValue(value: viewModel.sliderValue)
    }
}

class SimpleARView: ARView {
    var viewModel: ViewModel
    var arView: ARView { return self }
    var subscriptions = Set<AnyCancellable>()

    var planeAnchor: AnchorEntity?

    var sphere: SphereEntity!
    var box: BoxEntity!

    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
        
        setupEntities()

        setupSubscriptions()
    }
        
    func setupScene() {
        // Setup world tracking and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]
        arView.session.run(configuration)
    }

    func setupSubscriptions() {
        // Process UI signals.
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }
        .store(in: &subscriptions)

        // Observe slider value.
        viewModel.$sliderValue.sink { [weak self] value in
            self?.updateWithSliderValue(value: value)
        }
        .store(in: &subscriptions)
    }
    
    func processUISignal(_ signal: ViewModel.UISignal) {
        switch signal {
        case .reset:
            resetScene()
        }
    }

    // Define entities here.
    func setupEntities() {
        sphere = SphereEntity(name: "sphere", radius: 0.1, imageName: "checker.png")

        box = BoxEntity(name: "box", width: 0.2, height: 0.2, depth: 0.2, imageName: "checker.png")
    }
    
    // Reset plane anchor and position entities.
    func resetScene() {
        // Reset plane anchor. //
        planeAnchor?.removeFromParent()
        planeAnchor = nil
        planeAnchor = AnchorEntity(plane: [.horizontal])
        arView.scene.addAnchor(planeAnchor!)
        
        // Position and add sphere to scene.
        sphere.position.x = -0.2
        sphere.position.y = 0.1
        sphere.position.z = 0
        planeAnchor?.addChild(sphere)

        // Position and add box to scene.
        box.position.x = 0.2
        box.position.y = 0.1
        box.position.z = 0
        planeAnchor?.addChild(box)
    }
    
    func updateWithSliderValue(value: Float) {
        let scale = value * 2
        sphere.scale = [scale, scale, scale]

        updateSpiralStaircase()
    }
    
    func updateSpiralStaircase() {
        // Add/remove spiral staircase.
        box.children.removeAll()
        var lastBoxEntity = box!
        for _ in 0..<(Int(viewModel.sliderValue * 10)) {
            // Create and position new entity.
            let newEntity = box.clone(recursive: false)
            newEntity.position.x = 0.1
            newEntity.position.y = 0.1
            newEntity.position.z = 0

            // Rotate on y-axis by 45 degrees.
            newEntity.orientation = simd_quatf(angle: .pi / 4, axis: [0, 1, 0])

            // Add to last entity in tree.
            lastBoxEntity.addChild(newEntity)
            
            // Set last entity used.
            lastBoxEntity = newEntity
        }
    }
}
