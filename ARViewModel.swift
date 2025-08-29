import Foundation
import ARKit
import RealityKit
import Combine

class ARViewModel: NSObject, ObservableObject {
    @Published var isARSupported = ARWorldTrackingConfiguration.isSupported
    @Published var trackingState: ARCamera.TrackingState = .notAvailable
    @Published var currentPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @Published var isMarkerDetected = false
    @Published var navigationPath: [NavigationNode] = []
    
    private var arSession: ARSession?
    private var cancellables = Set<AnyCancellable>()
    
    // Navigation properties
    private var currentDestination: PointOfInterest?
    private var visualMarkers: [VisualMarker] = []
    private var navigationNodes: [NavigationNode] = []
    
    override init() {
        super.init()
        setupARSession()
        loadNavigationData()
    }
    
    private func setupARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("AR World Tracking not supported on this device")
            return
        }
        
        arSession = ARSession()
        arSession?.delegate = self
    }
    
    func startARSession() {
        guard let session = arSession else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable image tracking for visual markers
        if let referenceImages = loadReferenceImages() {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 10
        }
        
        // Enable plane detection for better tracking
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Enable location anchors if available (iOS 14+)
        if #available(iOS 14.0, *) {
            configuration.appClipCodeTrackingEnabled = true
        }
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func pauseARSession() {
        arSession?.pause()
    }
    
    private func loadReferenceImages() -> Set<ARReferenceImage>? {
        guard let path = Bundle.main.path(forResource: "ARImages", ofType: "arresourcegroup"),
              let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "ARImages", bundle: nil) else {
            print("Could not load AR reference images")
            return nil
        }
        
        return referenceImages
    }
    
    private func loadNavigationData() {
        // Load sample navigation data
        // In a real app, this would come from a server or local database
        
        // Sample visual markers
        visualMarkers = [
            VisualMarker(
                id: UUID(),
                name: "Entrance Marker",
                position: SIMD3<Float>(0, 0, 0),
                imageName: "entrance_marker"
            ),
            VisualMarker(
                id: UUID(),
                name: "Corridor Junction",
                position: SIMD3<Float>(10, 0, 0),
                imageName: "junction_marker"
            ),
            VisualMarker(
                id: UUID(),
                name: "Meeting Room Area",
                position: SIMD3<Float>(20, 0, 5),
                imageName: "meeting_room_marker"
            )
        ]
        
        // Sample navigation nodes
        navigationNodes = [
            NavigationNode(
                id: UUID(),
                position: SIMD3<Float>(0, 0, 0),
                nodeType: .entrance,
                connections: [UUID()]
            ),
            NavigationNode(
                id: UUID(),
                position: SIMD3<Float>(5, 0, 0),
                nodeType: .corridor,
                connections: [UUID(), UUID()]
            ),
            NavigationNode(
                id: UUID(),
                position: SIMD3<Float>(10, 0, 0),
                nodeType: .junction,
                connections: [UUID(), UUID(), UUID()]
            ),
            NavigationNode(
                id: UUID(),
                position: SIMD3<Float>(15, 0, 2),
                nodeType: .corridor,
                connections: [UUID(), UUID()]
            ),
            NavigationNode(
                id: UUID(),
                position: SIMD3<Float>(20, 0, 5),
                nodeType: .destination,
                connections: [UUID()]
            )
        ]
    }
    
    func startNavigation(to destination: PointOfInterest) {
        currentDestination = destination
        
        // Calculate path using A* algorithm
        if let path = calculatePath(to: destination) {
            navigationPath = path
            
            // Create AR visualization for the path
            createNavigationVisualization()
        }
    }
    
    private func calculatePath(to destination: PointOfInterest) -> [NavigationNode]? {
        // Simplified pathfinding - in a real app, this would use A* algorithm
        // For demo purposes, return a sample path
        return Array(navigationNodes.prefix(5))
    }
    
    private func createNavigationVisualization() {
        // This would create 3D arrows, path lines, and destination markers
        // Implementation would use RealityKit to create and position AR entities
    }
    
    func stopNavigation() {
        currentDestination = nil
        navigationPath = []
        // Remove AR visualization entities
    }
}

// MARK: - ARSessionDelegate
extension ARViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async {
            self.trackingState = frame.camera.trackingState
            self.currentPosition = frame.camera.transform.columns.3.xyz
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                handleImageAnchor(imageAnchor)
            }
        }
    }
    
    private func handleImageAnchor(_ imageAnchor: ARImageAnchor) {
        guard let imageName = imageAnchor.referenceImage.name else { return }
        
        DispatchQueue.main.async {
            self.isMarkerDetected = true
            
            // Find corresponding visual marker
            if let marker = self.visualMarkers.first(where: { $0.imageName == imageName }) {
                // Update position based on detected marker
                self.updatePositionFromMarker(marker, anchor: imageAnchor)
            }
        }
    }
    
    private func updatePositionFromMarker(_ marker: VisualMarker, anchor: ARImageAnchor) {
        // Update the AR coordinate system based on the detected marker
        // This provides accurate positioning for navigation
        let markerTransform = anchor.transform
        
        // Calculate offset from marker to current position
        // Update navigation visualization accordingly
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed with error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session interruption ended")
        // Restart the session
        startARSession()
    }
}

// MARK: - Helper Extensions
extension SIMD4<Float> {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

