# Architecture

A SwiftUI app for tvOS. Everything lives under `PhotoGuessingGame/`, organised
by role in the usual SwiftUI shape: an app entry point, views, view models and
models.

## Notes that are specific to tvOS

- **Input is a remote, not a pointer.** Every interactive element must be
  reachable by focus, and focus order is part of the design rather than a
  by-product of layout.
- **The screen is shared and far away.** Type sizes, contrast and hit targets are
  sized for a sofa, not a desk.
- **No file picker.** Photos come from the photo library through PhotoKit
  (`Services/PhotoService.swift`), or from a generated demo set when there is no
  library to read. Places are reverse-geocoded from each photo's GPS position
  through Nominatim (`Services/LocationService.swift`).

## Building

Open `PhotoGuessingGame.xcodeproj` in Xcode 15 or newer and run the tvOS target,
either in the simulator or on an Apple TV. See CONTRIBUTING.md for details.
