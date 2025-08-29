import Foundation
import ARKit

// MARK: - Core Data Models

struct PointOfInterest: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: String
    let floor: Int
    let description: String
    let position: SIMD3<Float>
    let tags: [String]
    
    init(id: UUID = UUID(), name: String, category: String, floor: Int, description: String, position: SIMD3<Float>, tags: [String] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.floor = floor
        self.description = description
        self.position = position
        self.tags = tags
    }
}

struct POICategory: Identifiable, Codable {
    let id: UUID
    let name: String
    let icon: String
    let color: ColorData
    
    init(id: UUID = UUID(), name: String, icon: String, color: ColorData) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
}

struct ColorData: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension ColorData {
    static let blue = ColorData(red: 0.0, green: 0.478, blue: 1.0)
    static let orange = ColorData(red: 1.0, green: 0.584, blue: 0.0)
    static let green = ColorData(red: 0.204, green: 0.780, blue: 0.349)
    static let purple = ColorData(red: 0.686, green: 0.322, blue: 0.871)
    static let red = ColorData(red: 1.0, green: 0.231, blue: 0.188)
    static let gray = ColorData(red: 0.557, green: 0.557, blue: 0.576)
}

struct NavigationNode: Identifiable, Codable {
    let id: UUID
    let position: SIMD3<Float>
    let nodeType: NodeType
    let connections: [UUID]
    let accessibility: AccessibilityInfo
    let floor: Int
    
    init(id: UUID = UUID(), position: SIMD3<Float>, nodeType: NodeType, connections: [UUID], accessibility: AccessibilityInfo = AccessibilityInfo(), floor: Int = 1) {
        self.id = id
        self.position = position
        self.nodeType = nodeType
        self.connections = connections
        self.accessibility = accessibility
        self.floor = floor
    }
}

enum NodeType: String, Codable, CaseIterable {
    case entrance = "entrance"
    case corridor = "corridor"
    case junction = "junction"
    case stairway = "stairway"
    case elevator = "elevator"
    case destination = "destination"
    case emergency = "emergency"
}

struct AccessibilityInfo: Codable {
    let wheelchairAccessible: Bool
    let hasElevatorAccess: Bool
    let hasRampAccess: Bool
    let visualAidSupport: Bool
    let audioAidSupport: Bool
    
    init(wheelchairAccessible: Bool = true, hasElevatorAccess: Bool = false, hasRampAccess: Bool = false, visualAidSupport: Bool = true, audioAidSupport: Bool = true) {
        self.wheelchairAccessible = wheelchairAccessible
        self.hasElevatorAccess = hasElevatorAccess
        self.hasRampAccess = hasRampAccess
        self.visualAidSupport = visualAidSupport
        self.audioAidSupport = audioAidSupport
    }
}

struct VisualMarker: Identifiable, Codable {
    let id: UUID
    let name: String
    let position: SIMD3<Float>
    let imageName: String
    let trackingQuality: TrackingQuality
    let associatedNodes: [UUID]
    let floor: Int
    
    init(id: UUID = UUID(), name: String, position: SIMD3<Float>, imageName: String, trackingQuality: TrackingQuality = .good, associatedNodes: [UUID] = [], floor: Int = 1) {
        self.id = id
        self.name = name
        self.position = position
        self.imageName = imageName
        self.trackingQuality = trackingQuality
        self.associatedNodes = associatedNodes
        self.floor = floor
    }
}

enum TrackingQuality: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
}

struct Building: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let floors: [Floor]
    let boundingBox: BoundingBox
    let visualMarkers: [VisualMarker]
    
    init(id: UUID = UUID(), name: String, address: String, floors: [Floor], boundingBox: BoundingBox, visualMarkers: [VisualMarker]) {
        self.id = id
        self.name = name
        self.address = address
        self.floors = floors
        self.boundingBox = boundingBox
        self.visualMarkers = visualMarkers
    }
}

struct Floor: Identifiable, Codable {
    let id: UUID
    let level: Int
    let name: String
    let pointsOfInterest: [PointOfInterest]
    let navigationNodes: [NavigationNode]
    let floorPlanImageName: String?
    
    init(id: UUID = UUID(), level: Int, name: String, pointsOfInterest: [PointOfInterest], navigationNodes: [NavigationNode], floorPlanImageName: String? = nil) {
        self.id = id
        self.level = level
        self.name = name
        self.pointsOfInterest = pointsOfInterest
        self.navigationNodes = navigationNodes
        self.floorPlanImageName = floorPlanImageName
    }
}

struct BoundingBox: Codable {
    let minX: Float
    let maxX: Float
    let minY: Float
    let maxY: Float
    let minZ: Float
    let maxZ: Float
    
    init(minX: Float, maxX: Float, minY: Float, maxY: Float, minZ: Float, maxZ: Float) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.minZ = minZ
        self.maxZ = maxZ
    }
}

// MARK: - Navigation Models

struct NavigationRoute: Identifiable {
    let id: UUID
    let destination: PointOfInterest
    let nodes: [NavigationNode]
    let totalDistance: Float
    let estimatedTime: TimeInterval
    let instructions: [NavigationInstruction]
    
    init(id: UUID = UUID(), destination: PointOfInterest, nodes: [NavigationNode], totalDistance: Float, estimatedTime: TimeInterval, instructions: [NavigationInstruction]) {
        self.id = id
        self.destination = destination
        self.nodes = nodes
        self.totalDistance = totalDistance
        self.estimatedTime = estimatedTime
        self.instructions = instructions
    }
}

struct NavigationInstruction: Identifiable {
    let id: UUID
    let type: InstructionType
    let description: String
    let distance: Float
    let position: SIMD3<Float>
    
    init(id: UUID = UUID(), type: InstructionType, description: String, distance: Float, position: SIMD3<Float>) {
        self.id = id
        self.type = type
        self.description = description
        self.distance = distance
        self.position = position
    }
}

enum InstructionType: String, CaseIterable {
    case start = "start"
    case straight = "straight"
    case turnLeft = "turn_left"
    case turnRight = "turn_right"
    case upstairs = "upstairs"
    case downstairs = "downstairs"
    case elevator = "elevator"
    case destination = "destination"
}

// MARK: - AR Tracking Models

struct ARTrackingState {
    let position: SIMD3<Float>
    let orientation: simd_quatf
    let trackingQuality: ARCamera.TrackingState
    let lastMarkerDetection: Date?
    let confidence: Float
    
    init(position: SIMD3<Float>, orientation: simd_quatf, trackingQuality: ARCamera.TrackingState, lastMarkerDetection: Date? = nil, confidence: Float = 1.0) {
        self.position = position
        self.orientation = orientation
        self.trackingQuality = trackingQuality
        self.lastMarkerDetection = lastMarkerDetection
        self.confidence = confidence
    }
}

// MARK: - Extensions for SIMD3<Float> Codable Support

extension SIMD3: Codable where Scalar: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Scalar.self)
        let y = try container.decode(Scalar.self)
        let z = try container.decode(Scalar.self)
        self.init(x, y, z)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(z)
    }
}

// MARK: - Utility Extensions

extension SIMD3 where Scalar: FloatingPoint {
    var length: Scalar {
        return sqrt(x * x + y * y + z * z)
    }
    
    func distance(to other: SIMD3<Scalar>) -> Scalar {
        return (self - other).length
    }
    
    var normalized: SIMD3<Scalar> {
        let len = length
        return len > 0 ? self / len : self
    }
}

extension PointOfInterest: Equatable {
    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
        return lhs.id == rhs.id
    }
}

extension NavigationNode: Equatable {
    static func == (lhs: NavigationNode, rhs: NavigationNode) -> Bool {
        return lhs.id == rhs.id
    }
}

