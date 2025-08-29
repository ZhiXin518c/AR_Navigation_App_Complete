# AR Navigation App

An augmented reality indoor navigation application built with ARKit for iOS devices. This app provides intuitive, visual navigation assistance within indoor environments using visual markers and advanced pathfinding algorithms.

## Features

- **Augmented Reality Navigation**: Real-time AR overlays with directional arrows and path visualization
- **Visual Marker Recognition**: High-accuracy positioning using custom visual markers
- **Intelligent Pathfinding**: A* algorithm with accessibility and preference considerations
- **Search and Discovery**: Comprehensive search for destinations with category filtering
- **Accessibility Support**: Full accessibility features including VoiceOver and high contrast mode
- **Multi-floor Navigation**: Support for complex buildings with multiple floors
- **Real-time Tracking**: Continuous position tracking with ARKit SLAM technology

## Requirements

### Device Requirements
- iPhone 6s or newer / iPad (5th generation) or newer
- iOS 12.0 or later (iOS 14.0+ recommended for Location Anchors)
- A9 processor or newer
- Rear-facing camera
- ARKit support

### Development Requirements
- Xcode 12.0 or later
- Swift 5.0 or later
- iOS SDK 12.0 or later

## Installation

### Option 1: Xcode Project Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo/ar-navigation-app.git
   cd ar-navigation-app
   ```

2. **Open in Xcode**:
   ```bash
   open ARNavigationApp.xcodeproj
   ```

3. **Configure signing**:
   - Select your development team in Project Settings > Signing & Capabilities
   - Ensure a unique bundle identifier is set

4. **Add AR Resources**:
   - Create an AR Resource Group named "ARImages.arresourcegroup"
   - Add your visual marker images to this resource group
   - Ensure images are high contrast and at least 300 DPI

5. **Build and run** on a physical device (AR requires a physical device)

### Option 2: Manual File Setup

If you're setting up the project manually:

1. **Create a new iOS project** in Xcode:
   - Choose "App" template
   - Select SwiftUI interface
   - Enable ARKit capability

2. **Add the source files**:
   - Copy all `.swift` files from the `Source/` directory
   - Add the `Info.plist` configuration

3. **Add frameworks**:
   - ARKit.framework
   - RealityKit.framework
   - AVFoundation.framework

4. **Configure capabilities**:
   - Camera usage
   - Location services
   - Motion sensors

## Project Structure

```
ARNavigationApp/
├── Source/
│   ├── ARNavigationApp.swift      # Main app entry point
│   ├── ContentView.swift          # Main UI view
│   ├── ARViewModel.swift          # AR session management
│   ├── ARViewContainer.swift      # RealityKit AR view
│   ├── SearchView.swift           # Destination search interface
│   ├── Models.swift               # Data models
│   ├── PathfindingService.swift   # A* pathfinding algorithm
│   └── Info.plist                 # App configuration
├── Resources/
│   └── ARImages.arresourcegroup/  # Visual marker images
├── Tests/
│   └── ARNavigationAppTests.swift # Unit tests
└── Documentation/
    └── API_Documentation.md       # Detailed API docs
```

## Usage

### Basic Navigation

1. **Launch the app** and grant camera permissions
2. **Search for a destination** using the search bar
3. **Select your destination** from the search results
4. **Scan a visual marker** to initialize positioning
5. **Follow the AR arrows** and path visualization to your destination

### Visual Marker Setup

For the app to work properly, visual markers must be placed throughout the environment:

1. **Print markers** at 20cm x 20cm minimum size
2. **Place markers** at key locations (entrances, junctions, destinations)
3. **Ensure good lighting** and unobstructed views
4. **Update marker database** with precise positions

### Customization

#### Adding New Destinations

Edit the `loadSearchData()` function in `SearchView.swift`:

```swift
let newPOI = PointOfInterest(
    name: "New Destination",
    category: "Custom Category",
    floor: 1,
    description: "Description of the location",
    position: SIMD3<Float>(x, y, z) // 3D coordinates
)
```

#### Configuring Navigation Preferences

Modify navigation behavior in `PathfindingService.swift`:

```swift
let preferences = NavigationPreferences(
    requireWheelchairAccess: true,
    avoidStairs: true,
    preferElevators: true,
    walkingSpeed: 1.2 // meters per second
)
```

## Architecture

### Core Components

- **ARViewModel**: Manages ARKit session, tracking, and marker detection
- **PathfindingService**: Implements A* algorithm for optimal route calculation
- **ARViewContainer**: Handles 3D AR visualization using RealityKit
- **SearchView**: Provides destination search and selection interface

### Data Flow

1. **Marker Detection**: ARKit detects visual markers and provides position anchors
2. **Position Tracking**: Continuous SLAM tracking maintains user position
3. **Route Calculation**: A* algorithm calculates optimal path to destination
4. **AR Visualization**: RealityKit renders 3D arrows, paths, and markers
5. **UI Updates**: SwiftUI interface updates with navigation information

### Navigation Algorithm

The app uses a modified A* pathfinding algorithm that considers:

- **Distance**: Euclidean distance between navigation nodes
- **Accessibility**: Wheelchair access, elevator availability
- **User Preferences**: Stairs vs. elevators, walking speed
- **Node Types**: Different costs for corridors, junctions, stairways
- **Floor Changes**: Penalties for multi-floor navigation

## Testing

### Unit Tests

Run unit tests in Xcode:
```bash
⌘ + U
```

### Manual Testing Checklist

- [ ] AR session starts successfully
- [ ] Visual markers are detected accurately
- [ ] Search functionality works correctly
- [ ] Navigation path is calculated properly
- [ ] AR visualization appears correctly
- [ ] Voice instructions are clear
- [ ] Accessibility features function properly

### Performance Testing

Monitor performance metrics:
- Frame rate should maintain 30+ FPS
- Memory usage should stay under 512 MB
- Battery drain should allow 2+ hours of use

## Troubleshooting

### Common Issues

**AR session fails to start**:
- Ensure device supports ARKit
- Check camera permissions
- Verify adequate lighting

**Markers not detected**:
- Check marker print quality (300+ DPI)
- Ensure markers are well-lit
- Verify marker images in AR resource group

**Poor tracking performance**:
- Improve lighting conditions
- Add more visual features to environment
- Reduce device movement speed

**Navigation accuracy issues**:
- Recalibrate by scanning multiple markers
- Update marker position database
- Check for environmental changes

### Performance Optimization

- Limit concurrent AR entities to improve frame rate
- Use LOD (Level of Detail) for distant objects
- Optimize marker detection frequency
- Cache navigation calculations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Document public APIs
- Write unit tests for new features

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Apple's ARKit team for the excellent AR framework
- RealityKit for 3D rendering capabilities
- The AR development community for inspiration and best practices

## Support

For issues and questions:
- Create an issue on GitHub
- Check the documentation in the `Documentation/` folder
- Review the troubleshooting section above

## Roadmap

### Version 1.1
- [ ] Android ARCore support
- [ ] Cloud anchor synchronization
- [ ] Multi-user navigation
- [ ] Voice command integration

### Version 1.2
- [ ] Outdoor navigation integration
- [ ] Real-time crowd density
- [ ] Advanced accessibility features
- [ ] Analytics and usage tracking

