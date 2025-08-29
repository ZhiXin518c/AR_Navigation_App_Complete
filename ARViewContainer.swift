import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure the AR view
        arView.automaticallyConfigureSession = false
        arView.session.delegate = arViewModel
        
        // Start the AR session
        arViewModel.startARSession()
        
        // Set up the AR scene
        setupARScene(arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR visualization based on navigation state
        updateNavigationVisualization(uiView)
    }
    
    private func setupARScene(_ arView: ARView) {
        // Create anchor for AR content
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, 0))
        arView.scene.addAnchor(anchor)
        
        // Add lighting
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 1000
        directionalLight.orientation = simd_quatf(angle: -.pi/3, axis: [1, 0, 0])
        anchor.addChild(directionalLight)
    }
    
    private func updateNavigationVisualization(_ arView: ARView) {
        guard !arViewModel.navigationPath.isEmpty else { return }
        
        // Remove existing navigation entities
        removeNavigationEntities(from: arView)
        
        // Create new navigation visualization
        createNavigationPath(in: arView)
        createNavigationArrows(in: arView)
        createDestinationMarker(in: arView)
    }
    
    private func removeNavigationEntities(from arView: ARView) {
        // Remove entities with navigation tags
        for anchor in arView.scene.anchors {
            let entitiesToRemove = anchor.children.filter { entity in
                entity.name.hasPrefix("navigation_")
            }
            
            for entity in entitiesToRemove {
                entity.removeFromParent()
            }
        }
    }
    
    private func createNavigationPath(in arView: ARView) {
        guard let anchor = arView.scene.anchors.first else { return }
        
        let pathNodes = arViewModel.navigationPath
        
        for i in 0..<pathNodes.count - 1 {
            let startPos = pathNodes[i].position
            let endPos = pathNodes[i + 1].position
            
            // Create path line segment
            let pathEntity = createPathLine(from: startPos, to: endPos)
            pathEntity.name = "navigation_path_\(i)"
            anchor.addChild(pathEntity)
        }
    }
    
    private func createPathLine(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Entity {
        let distance = length(end - start)
        let midpoint = (start + end) / 2
        
        // Create a thin cylinder to represent the path
        let mesh = MeshResource.generateBox(
            width: 0.05,
            height: 0.01,
            depth: distance
        )
        
        var material = SimpleMaterial()
        material.color = .init(tint: .blue, texture: nil)
        material.metallic = 0.0
        material.roughness = 0.5
        
        let pathEntity = ModelEntity(mesh: mesh, materials: [material])
        pathEntity.position = midpoint
        
        // Rotate to align with path direction
        let direction = normalize(end - start)
        let angle = atan2(direction.x, direction.z)
        pathEntity.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
        
        return pathEntity
    }
    
    private func createNavigationArrows(in arView: ARView) {
        guard let anchor = arView.scene.anchors.first else { return }
        
        let pathNodes = arViewModel.navigationPath
        
        // Create arrows at key navigation points
        for (index, node) in pathNodes.enumerated() {
            if index < pathNodes.count - 1 {
                let nextNode = pathNodes[index + 1]
                let arrowEntity = createNavigationArrow(
                    at: node.position,
                    pointingTo: nextNode.position
                )
                arrowEntity.name = "navigation_arrow_\(index)"
                anchor.addChild(arrowEntity)
            }
        }
    }
    
    private func createNavigationArrow(at position: SIMD3<Float>, pointingTo target: SIMD3<Float>) -> Entity {
        // Create arrow mesh (simplified cone shape)
        let mesh = MeshResource.generateBox(width: 0.3, height: 0.1, depth: 0.6)
        
        var material = SimpleMaterial()
        material.color = .init(tint: .blue, texture: nil)
        material.metallic = 0.2
        material.roughness = 0.3
        
        let arrowEntity = ModelEntity(mesh: mesh, materials: [material])
        arrowEntity.position = position + SIMD3<Float>(0, 0.1, 0) // Slightly above ground
        
        // Point arrow toward target
        let direction = normalize(target - position)
        let angle = atan2(direction.x, direction.z)
        arrowEntity.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])
        
        // Add pulsing animation
        let pulseAnimation = AnimationResource.makeTransform(
            duration: 1.0,
            repeatMode: .repeat,
            autoreverses: true,
            translation: .init(repeating: 0),
            rotation: .init(angle: 0, axis: [0, 1, 0]),
            scale: .init(from: [1, 1, 1], to: [1.2, 1.2, 1.2])
        )
        
        arrowEntity.playAnimation(pulseAnimation)
        
        return arrowEntity
    }
    
    private func createDestinationMarker(in arView: ARView) {
        guard let anchor = arView.scene.anchors.first,
              let lastNode = arViewModel.navigationPath.last else { return }
        
        // Create destination beacon
        let mesh = MeshResource.generateSphere(radius: 0.2)
        
        var material = SimpleMaterial()
        material.color = .init(tint: .green, texture: nil)
        material.metallic = 0.1
        material.roughness = 0.2
        
        let destinationEntity = ModelEntity(mesh: mesh, materials: [material])
        destinationEntity.position = lastNode.position + SIMD3<Float>(0, 0.5, 0)
        destinationEntity.name = "navigation_destination"
        
        // Add floating animation
        let floatAnimation = AnimationResource.makeTransform(
            duration: 2.0,
            repeatMode: .repeat,
            autoreverses: true,
            translation: .init(from: [0, 0, 0], to: [0, 0.2, 0]),
            rotation: .init(angle: 0, axis: [0, 1, 0]),
            scale: .init(repeating: 1)
        )
        
        destinationEntity.playAnimation(floatAnimation)
        
        anchor.addChild(destinationEntity)
    }
}

#Preview {
    ARViewContainer(arViewModel: ARViewModel())
}

