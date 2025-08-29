
# ARCore vs. ARKit for Indoor Positioning

## Introduction
Both ARCore (Android) and ARKit (iOS) provide common features like motion tracking, light estimation, image tracking, anchors, and cloud anchors for AR applications.

## Augmented Images
- Both can track known images to align AR world coordinates with real-world coordinates.
- ARCore requires the image to fill at least 25% of the camera frame for initial detection, with an average of 0.65 degrees offset in image norm direction and 2.5 degrees offset in other two axes.
- ARKit is faster and more accurate, not requiring the image to fill as much of the view, with an average of 0.29 degrees offset in image norm direction and 0.64 degrees offset in other two axes.
- Similar images should be avoided to prevent confusion.
- ARCore's world coordinate cannot be reset, so image coordinates are child to it. ARKit's world coordinate can be reset to match the image coordinate.

## Motion Tracking & SLAM
- Both use SLAM algorithms with camera, IMU, and other sensors.
- ARCore relies more on re-localization, leading to more frequent jumps but higher accuracy. ARKit provides a smoother experience but is less accurate.
- Lidar cameras (new iPad/iPhone) significantly improve motion tracking to centimeter-level accuracy.
- ARKit is more robust when the camera loses track (no features in view) compared to ARCore.

## Depth API
- ARCore Depth API (June 2020) uses depth-from-motion on normal cameras.
- ARKit Depth API (ARKit 3.5) requires a lidar camera and integrates lidar results automatically for motion tracking.




## Overview of Indoor Navigation Technologies
- **GPS:** Not suitable for indoor navigation due to insufficient accuracy (only defines building, not precise indoor location).
- **Beacons:** Provide better accuracy (within 5 meters) but require physical placement and location storage. Useful for general navigation within large spaces like airports.
- **Visual Positioning System (VPS):** Uses smartphone camera to analyze surroundings and determine location. Requires creating custom datasets and training AI models for indoor environments. Challenges with remodeling or frequent furniture movement. Can supplement GPS or Beacons.
- **Visual Markers:** Images recognized by the system. Most cost-effective and highest accuracy among indoor options. Requires users to scan markers periodically, which can be less seamless. Marker maintenance is crucial.

## AR Navigation: How It Works
- Combines indoor navigation technologies with AR to overlay directions (text, arrows, paths) onto the real environment seen through a device camera.
- The main challenge is identifying the user's precise position; displaying AR directions is the easier part.

## Current Limitations of AR Indoor Navigation Technology
- Current AR indoor navigation provides general direction (e.g., to a store department, hospital ward) but lacks centimeter-accuracy for specific items (e.g., product on a shelf).
- High precision requires high performance and significant investment in technology.

## Mobile AR Indoor Navigation: ARCore and ARKit
- **ARKit (iOS):** Backed by more reliable hardware/software due to Apple's control over production. More optimized and reliable performance with less diversity among devices.
  - **ARKit Location Anchors (ARKit 4):** Uses VPS to identify landmarks and compare with Apple Maps Look Around images. Allows affixing objects to specific locations with higher accuracy than GPS alone. Location matching occurs locally, addressing privacy concerns.
- **ARCore (Android):** Less powerful than ARKit due to hardware limitations and inconsistencies.

## Conclusion for Technology Selection
Based on the research, ARKit appears to offer superior performance and accuracy for indoor AR navigation, especially with its Location Anchors feature and tighter hardware/software integration. While ARCore is viable, ARKit's robustness and precision make it a more suitable choice for a high-quality AR indoor navigation application. We will prioritize ARKit for development, while keeping in mind that the core navigation data and routing logic can be cross-platform.


