# CLAUDE.md - Photo Guessing Game (tvOS)

## Project Overview

A two-player party game for Apple TV where players guess when and where photos were taken. Native tvOS port built with SwiftUI and optimized for the Apple TV Siri Remote navigation experience.

## Game Modes

### Date Mode ("When Was It?")
Players guess when photos were taken in three phases:
1. **Year** (1 point) - Select from 8 year options
2. **Month** (2 points) - Select from 12 months
3. **Day** (3 points) - Select from calendar grid

### Location Mode ("Where Was It?")
Players guess where photos were taken in three phases:
1. **Country** (1 point) - Select from 5 options
2. **State/Region** (2 points) - Select from 5 options
3. **City** (3 points) - Select from 5 options

## Scoring
- Correct guesses accumulate points through phases (max 6 points per photo)
- Wrong guess ends turn but keeps accumulated points
- First player to 10 points wins (with tie-breaker system)
- Perfect 6-point guesses trigger confetti celebration

## Project Structure

```
PhotoGuessingGame/
├── PhotoGuessingGameApp.swift    # App entry point
├── ContentView.swift             # Main view router
├── Info.plist                    # App configuration
├── Assets.xcassets/              # App icons and colors
├── Models/
│   └── GameModels.swift          # Data models (Player, Photo, GamePhase, etc.)
├── ViewModels/
│   └── GameViewModel.swift       # Game state management
├── Views/
│   ├── SetupView.swift           # Player setup and mode selection
│   ├── PhotoLoaderView.swift     # Photo loading UI
│   ├── GameBoardView.swift       # Main game layout
│   ├── PhotoDisplayView.swift    # Photo display with counter
│   ├── PlayerPanelView.swift     # Player score and status
│   ├── GuessingInterfaceView.swift # Phase-specific selector host
│   ├── YearSelectorView.swift    # Year selection grid
│   ├── MonthSelectorView.swift   # Month selection grid
│   ├── DaySelectorView.swift     # Calendar-style day grid
│   ├── CountrySelectorView.swift # Country options list
│   ├── StateSelectorView.swift   # State options list
│   ├── CitySelectorView.swift    # City options list
│   ├── FeedbackOverlayView.swift # Correct/incorrect feedback
│   ├── VictoryView.swift         # Winner celebration
│   ├── ConfettiView.swift        # Particle effects
│   └── FocusableButton.swift     # TV-optimized button components
├── Services/
│   ├── PhotoService.swift        # PhotoKit integration
│   ├── SoundService.swift        # Synthesized sound effects
│   └── LocationService.swift     # Reverse geocoding (Nominatim)
└── Utils/
    └── GameUtils.swift           # Helper functions
```

## Key Files

| File | Purpose |
|------|---------|
| `GameViewModel.swift` | Central game state, scoring logic, turn management |
| `GameModels.swift` | All data types (Player, GamePhoto, GuessPhase, etc.) |
| `PhotoService.swift` | Load photos from device library via PhotoKit |
| `SoundService.swift` | AVFoundation-based synthesized sound effects |
| `LocationService.swift` | OpenStreetMap Nominatim API for reverse geocoding |

## Requirements

- tvOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Building

1. Open `PhotoGuessingGame.xcodeproj` in Xcode
2. Select an Apple TV simulator or device
3. Build and run (Cmd+R)

## Photo Loading

The app supports two methods for loading photos:

### From Photo Library
- Uses PhotoKit to access the device's photo library
- Requires photo library permission (configured in Info.plist)
- Extracts EXIF date metadata and GPS coordinates
- GPS coordinates are reverse geocoded via Nominatim API

### Demo Mode
- Generates synthetic photos with random dates and locations
- Useful for testing without real photos

## tvOS Navigation

The app is optimized for Siri Remote navigation:
- Focus-based navigation with visual feedback
- Large touch targets for easy selection
- Scale animations on focused elements
- Spring animations for smooth transitions

## Sound Effects

All sounds are synthesized using AVFoundation (no external audio files):
- **Click**: Short 800Hz sine tone
- **Correct**: Ascending arpeggio (C5-E5-G5)
- **Incorrect**: Descending sawtooth sweep
- **Victory**: Chord progression fanfare

## Related Projects

This is the tvOS version of the Photo Guessing Game. See also:
- `reactjs-projects/photo-guessing-game` - React/Capacitor version for web/iOS/Android
