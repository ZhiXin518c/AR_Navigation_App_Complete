import Foundation

class PathfindingService {
    static let shared = PathfindingService()
    
    private init() {}
    
    // MARK: - A* Pathfinding Algorithm
    
    func findPath(
        from startPosition: SIMD3<Float>,
        to destination: PointOfInterest,
        using nodes: [NavigationNode],
        preferences: NavigationPreferences = NavigationPreferences()
    ) -> NavigationRoute? {
        
        // Find the closest nodes to start and end positions
        guard let startNode = findClosestNode(to: startPosition, in: nodes),
              let endNode = findClosestNode(to: destination.position, in: nodes) else {
            return nil
        }
        
        // Run A* algorithm
        let pathNodes = aStarSearch(from: startNode, to: endNode, in: nodes, preferences: preferences)
        
        guard !pathNodes.isEmpty else { return nil }
        
        // Calculate route metrics
        let totalDistance = calculateTotalDistance(pathNodes)
        let estimatedTime = calculateEstimatedTime(distance: totalDistance, preferences: preferences)
        let instructions = generateNavigationInstructions(for: pathNodes)
        
        return NavigationRoute(
            destination: destination,
            nodes: pathNodes,
            totalDistance: totalDistance,
            estimatedTime: estimatedTime,
            instructions: instructions
        )
    }
    
    private func aStarSearch(
        from start: NavigationNode,
        to goal: NavigationNode,
        in allNodes: [NavigationNode],
        preferences: NavigationPreferences
    ) -> [NavigationNode] {
        
        var openSet: Set<UUID> = [start.id]
        var cameFrom: [UUID: UUID] = [:]
        var gScore: [UUID: Float] = [start.id: 0]
        var fScore: [UUID: Float] = [start.id: heuristic(from: start, to: goal)]
        
        let nodeMap = Dictionary(uniqueKeysWithValues: allNodes.map { ($0.id, $0) })
        
        while !openSet.isEmpty {
            // Find node in openSet with lowest fScore
            let current = openSet.min { nodeId1, nodeId2 in
                (fScore[nodeId1] ?? Float.infinity) < (fScore[nodeId2] ?? Float.infinity)
            }!
            
            if current == goal.id {
                // Reconstruct path
                return reconstructPath(cameFrom: cameFrom, current: current, nodeMap: nodeMap)
            }
            
            openSet.remove(current)
            
            guard let currentNode = nodeMap[current] else { continue }
            
            // Check all neighbors
            for neighborId in currentNode.connections {
                guard let neighbor = nodeMap[neighborId] else { continue }
                
                let tentativeGScore = (gScore[current] ?? Float.infinity) + 
                    calculateMovementCost(from: currentNode, to: neighbor, preferences: preferences)
                
                if tentativeGScore < (gScore[neighborId] ?? Float.infinity) {
                    cameFrom[neighborId] = current
                    gScore[neighborId] = tentativeGScore
                    fScore[neighborId] = tentativeGScore + heuristic(from: neighbor, to: goal)
                    
                    if !openSet.contains(neighborId) {
                        openSet.insert(neighborId)
                    }
                }
            }
        }
        
        return [] // No path found
    }
    
    private func heuristic(from node1: NavigationNode, to node2: NavigationNode) -> Float {
        // Euclidean distance heuristic
        return node1.position.distance(to: node2.position)
    }
    
    private func calculateMovementCost(
        from node1: NavigationNode,
        to node2: NavigationNode,
        preferences: NavigationPreferences
    ) -> Float {
        
        let baseDistance = node1.position.distance(to: node2.position)
        var cost = baseDistance
        
        // Apply accessibility preferences
        if preferences.requireWheelchairAccess {
            if !node2.accessibility.wheelchairAccessible {
                cost *= 10.0 // Heavy penalty for inaccessible routes
            }
        }
        
        // Apply node type preferences
        switch node2.nodeType {
        case .stairway:
            if preferences.avoidStairs {
                cost *= 5.0
            }
        case .elevator:
            if preferences.preferElevators {
                cost *= 0.8 // Slight preference for elevators
            } else {
                cost *= 1.2 // Slight penalty if not preferred
            }
        case .emergency:
            cost *= 2.0 // Generally avoid emergency routes unless necessary
        default:
            break
        }
        
        // Floor change penalty
        if node1.floor != node2.floor {
            cost += preferences.floorChangePenalty
        }
        
        return cost
    }
    
    private func reconstructPath(
        cameFrom: [UUID: UUID],
        current: UUID,
        nodeMap: [UUID: NavigationNode]
    ) -> [NavigationNode] {
        
        var path: [NavigationNode] = []
        var currentId = current
        
        while let node = nodeMap[currentId] {
            path.insert(node, at: 0)
            
            if let previousId = cameFrom[currentId] {
                currentId = previousId
            } else {
                break
            }
        }
        
        return path
    }
    
    private func findClosestNode(to position: SIMD3<Float>, in nodes: [NavigationNode]) -> NavigationNode? {
        return nodes.min { node1, node2 in
            node1.position.distance(to: position) < node2.position.distance(to: position)
        }
    }
    
    private func calculateTotalDistance(_ nodes: [NavigationNode]) -> Float {
        guard nodes.count > 1 else { return 0 }
        
        var totalDistance: Float = 0
        for i in 0..<nodes.count - 1 {
            totalDistance += nodes[i].position.distance(to: nodes[i + 1].position)
        }
        
        return totalDistance
    }
    
    private func calculateEstimatedTime(distance: Float, preferences: NavigationPreferences) -> TimeInterval {
        // Average walking speed: 1.4 m/s (5 km/h)
        let walkingSpeed: Float = preferences.walkingSpeed
        let timeInSeconds = distance / walkingSpeed
        
        // Add buffer for turns, stops, etc.
        let bufferMultiplier: Float = 1.2
        
        return TimeInterval(timeInSeconds * bufferMultiplier)
    }
    
    private func generateNavigationInstructions(for nodes: [NavigationNode]) -> [NavigationInstruction] {
        guard nodes.count > 1 else { return [] }
        
        var instructions: [NavigationInstruction] = []
        
        // Start instruction
        instructions.append(NavigationInstruction(
            type: .start,
            description: "Start navigation",
            distance: 0,
            position: nodes[0].position
        ))
        
        // Generate turn-by-turn instructions
        for i in 1..<nodes.count {
            let previousNode = nodes[i - 1]
            let currentNode = nodes[i]
            let distance = previousNode.position.distance(to: currentNode.position)
            
            let instruction = generateInstruction(
                from: previousNode,
                to: currentNode,
                distance: distance,
                nextNode: i < nodes.count - 1 ? nodes[i + 1] : nil
            )
            
            instructions.append(instruction)
        }
        
        // Destination instruction
        if let lastNode = nodes.last {
            instructions.append(NavigationInstruction(
                type: .destination,
                description: "You have arrived at your destination",
                distance: 0,
                position: lastNode.position
            ))
        }
        
        return instructions
    }
    
    private func generateInstruction(
        from previousNode: NavigationNode,
        to currentNode: NavigationNode,
        distance: Float,
        nextNode: NavigationNode?
    ) -> NavigationInstruction {
        
        let distanceText = formatDistance(distance)
        
        // Determine instruction type based on node types and geometry
        let instructionType: InstructionType
        let description: String
        
        switch currentNode.nodeType {
        case .stairway:
            if currentNode.floor > previousNode.floor {
                instructionType = .upstairs
                description = "Go upstairs for \(distanceText)"
            } else {
                instructionType = .downstairs
                description = "Go downstairs for \(distanceText)"
            }
            
        case .elevator:
            instructionType = .elevator
            description = "Take elevator to floor \(currentNode.floor)"
            
        case .junction:
            if let next = nextNode {
                let turnDirection = calculateTurnDirection(
                    from: previousNode.position,
                    through: currentNode.position,
                    to: next.position
                )
                
                switch turnDirection {
                case .left:
                    instructionType = .turnLeft
                    description = "Turn left and continue for \(distanceText)"
                case .right:
                    instructionType = .turnRight
                    description = "Turn right and continue for \(distanceText)"
                case .straight:
                    instructionType = .straight
                    description = "Continue straight for \(distanceText)"
                }
            } else {
                instructionType = .straight
                description = "Continue for \(distanceText)"
            }
            
        default:
            instructionType = .straight
            description = "Continue for \(distanceText)"
        }
        
        return NavigationInstruction(
            type: instructionType,
            description: description,
            distance: distance,
            position: currentNode.position
        )
    }
    
    private func calculateTurnDirection(
        from start: SIMD3<Float>,
        through middle: SIMD3<Float>,
        to end: SIMD3<Float>
    ) -> TurnDirection {
        
        let vector1 = middle - start
        let vector2 = end - middle
        
        // Calculate cross product to determine turn direction
        let crossProduct = vector1.x * vector2.z - vector1.z * vector2.x
        
        let threshold: Float = 0.1
        
        if crossProduct > threshold {
            return .left
        } else if crossProduct < -threshold {
            return .right
        } else {
            return .straight
        }
    }
    
    private func formatDistance(_ distance: Float) -> String {
        if distance < 1.0 {
            return String(format: "%.0f cm", distance * 100)
        } else if distance < 100.0 {
            return String(format: "%.1f m", distance)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
}

// MARK: - Supporting Types

enum TurnDirection {
    case left
    case right
    case straight
}

struct NavigationPreferences {
    let requireWheelchairAccess: Bool
    let avoidStairs: Bool
    let preferElevators: Bool
    let walkingSpeed: Float // meters per second
    let floorChangePenalty: Float
    
    init(
        requireWheelchairAccess: Bool = false,
        avoidStairs: Bool = false,
        preferElevators: Bool = false,
        walkingSpeed: Float = 1.4, // Average walking speed
        floorChangePenalty: Float = 10.0
    ) {
        self.requireWheelchairAccess = requireWheelchairAccess
        self.avoidStairs = avoidStairs
        self.preferElevators = preferElevators
        self.walkingSpeed = walkingSpeed
        self.floorChangePenalty = floorChangePenalty
    }
}

