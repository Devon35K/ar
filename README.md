# AR Motion Smasher: The Last Warden

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue.svg)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-API_24+-green.svg)](https://developer.android.com)
[![ARCore](https://img.shields.io/badge/ARCore-1.47+-orange.svg)](https://developers.google.com/ar)
[![License](https://img.shields.io/badge/license-Academic-red.svg)]()

> **Antigravity IDE — Game Design Document**  
> **University of Southeastern Philippines — ICE 323 Professional Elective 3**  
> **April 2026**

An augmented reality mobile game where you physically cast spells using hand gestures to destroy falling 3D pixel-art meteors in real space. Built with **Flutter**, **CameraX**, and **MediaPipe** hand tracking. Unlike traditional AR games, this project uses a custom **Pseudo-AR** engine that works on all modern Android devices, including those without official ARCore support.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Story: The Last Warden](#story-the-last-warden)
3. [AR Features](#ar-features)
4. [Hand Tracking & Gesture System](#hand-tracking--gesture-system)
5. [Technical Architecture](#technical-architecture)
6. [Game Mechanics](#game-mechanics)
7. [File Structure](#file-structure)
8. [Build Instructions](#build-instructions)
9. [Team](#team)

---

## Project Overview

AR Motion Smasher is an **augmented reality game** that combines physical movement with spatial computing. The player uses their hand as a magical gauntlet to cast spells at 3D meteors falling through their real-world space.

### Core Concept
- **Physical interaction**: Your hand IS the controller
- **Augmented reality**: Meteors appear in your actual environment via ARCore
- **Educational gameplay**: Collect letters to spell words and unlock spells
- **Story-driven**: 5-wave narrative arc with boss battle

### Platform
- **Primary**: Flutter Android with ARCore
- **Minimum API**: Android 7.0 (API 24)
- **AR Requirements**: ARCore-compatible device

### Tech Stack
| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.11+ |
| AR Engine | Custom Pseudo-AR (via CameraSpaceScanner) |
| Hand Tracking | Google MediaPipe Tasks Vision |
| 3D Rendering | Flutter Custom Graphics & Animations |
| Backend | Flask + Python (optional, for prototyping) |

---

## Story: The Last Warden

### Narrative
Earth's orbit has been breached by a rogue asteroid belt from beyond the Rift. You are the **Last Warden** — a guardian whose enchanted gauntlet can channel ancient elemental spells. Destroy the meteors, collect the letters they drop, and rebuild the ancient **Warden Codex** to seal the Rift forever.

### Wave Progression

| Wave | Enemy Type | Story Beat | Letter Drop | Spell Unlocked |
|------|-----------|------------|-------------|----------------|
| 1 | Dust Rocks (Gray Cubes) | "First tremors detected" | E, A, R, T, H | None (basic smash) |
| 2 | Fire Meteors (Orange Spheres) | "The belt ignites" | F, I, R, E | 🔥 Fireball (swipe up) |
| 3 | Ice Shards (Cyan Icosahedrons) | "Cryo-storm approaching" | S, T, O, R, M | ⚡ Electric Charge (palm push) |
| 4 | Shadow Orbs (Dark Torus) | "The Rift opens" | V, O, I, D | 🌀 Void Pulse (circle gesture) |
| 5 | Boss Meteor (Composite) | "The Warden's Last Stand" | W, A, R, D, E, N | ✨ Codex Seal (all spells combined) |

### NPC Characters
| NPC | Appears After | Role | Educational Hook |
|-----|---------------|------|-----------------|
| Elder Kael | Wave 1 | Warden trainer | Teaches letter-to-spell mechanic |
| Archive Spirit | Wave 3 | Codex keeper | Reads collected words aloud, defines them |
| The Rift Oracle | Wave 5 | Final challenge | Recaps all story words collected |

---

## AR Features (Pseudo-AR Implementation)

### Custom Camera Space Scanner
This app uses a custom computer-vision-based scanner instead of Google ARCore, making it compatible with a wider range of devices:

#### Environment Analysis
- **Motion Detection**: Analyzes pixel changes between frames to detect movement in the user's environment.
- **Edge Detection**: Uses gradient analysis to find detail-rich areas for better spatial anchoring.
- **Virtual Grid**: Divides the camera feed into a grid (8x8) to map out high-confidence zones.

#### Simulated Depth
- **Heuristic Mapping**: Objects are placed with simulated depth based on their vertical position in the frame (lower = "closer").
- **Dynamic Spawning**: Meteors spawn in "spawn zones" identified by the scanner as having sufficient environmental detail.

#### Persistence
- **Hand-Centric Coordinates**: Tracking is relative to the user's camera view, ensuring consistent gameplay even as the device moves.

### Pseudo-AR Scene Implementation
```
CameraView (Standard CameraX)
├── MediaPipe Hand Tracking (21 Landmarks)
├── CameraSpaceScanner (Motion + Edge Analysis)
├── Virtual Spawn Zones (Mapped Grid)
├── Meteor System (Pseudo-3D Projection)
└── Spell Effects (Flutter Animated Overlays)
```

---

## Hand Tracking & Gesture System

### MediaPipe Integration
Uses **MediaPipe Tasks Vision 0.10.26** for robust hand landmark detection:
- **21 hand landmarks**: Full skeletal hand tracking
- **Real-time processing**: 30+ FPS on modern devices
- **GPU acceleration**: Delegated to GPU for performance

### Detected Gestures

| Gesture | Detection Method | Action | Visual Feedback |
|---------|-----------------|--------|---------------|
| **Hand Position** | Centroid of 21 landmarks | Moves 3D gauntlet cursor | Glowing fist mesh follows hand |
| **Swipe Up** | Wrist Y velocity > threshold (8 frames) | Fireball spell | Orange projectile fires upward |
| **Palm Push** | Palm facing camera + fingers extended + Z velocity | Electric Charge burst | Blue shockwave from fist |
| **Circle** | Centroid path curvature ≥ 270° over 20 frames | Void Pulse (AOE) | Purple ring expands |
| **Open Palm Hold** | Palm open + still for 1.5s | NPC dialogue trigger | Radial progress ring fills |
| **Fist Collision** | Distance from fist to meteor < threshold | Smash meteor | Pixel explosion + letter drop |

### Gesture Confidence Thresholds
```kotlin
// MediaPipe configuration
minHandDetectionConfidence = 0.5f
minHandTrackingConfidence = 0.5f
minHandPresenceConfidence = 0.5f
maxNumHands = 1
```

---

## Technical Architecture

### System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter Layer                         │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │  Game State    │  │  Gesture Bridge│  │  UI Overlay    │ │
│  │  (Dart)        │  │  (MethodChannel)│  │  (Widgets)     │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │ Platform Channel
┌──────────────────────────▼──────────────────────────────────┐
│                     Android Native                           │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │ CameraX View   │  │ MediaPipe      │  │ Game Logic     │   │
│  │ (PreviewView)  │  │ Hand Tracking  │  │ (Kotlin)       │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐                    │
│  │ Space Scanner  │  │ Camera Overlay │                    │
│  │ (Custom CV)    │  │ (Native Canvas)│                    │
│  └────────────────┘  └────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### Android Native (Kotlin)
| File | Responsibility |
|------|---------------|
| `MainActivity.kt` | Flutter engine setup, permission handling |
| `CameraSpaceScanner.kt` | Custom environment analysis (no ARCore) |
| `MyCameraView.kt` | CameraX feed + Space scanning integration |
| `GestureRecognizerHelper.kt` | MediaPipe Tasks Vision wrapper |
| `OverlayView.kt` | Custom canvas drawing for debug/scanning |

#### Flutter (Dart)
| File | Responsibility |
|------|---------------|
| `main.dart` | App entry, fullscreen, orientation lock |
| `landing_page.dart` | Story intro, play button |
| `my_camera_view.dart` | Platform view wrapper for AR + hand tracking |

---

## Game Mechanics

### Meteor System
Meteors spawn in AR space and fall toward the player. Each wave has unique geometry:

```dart
const WAVES = [
  {
    id: 1,
    name: "Dust Rocks",
    geometry: "box",           // BoxGeometry
    color: 0x888888,
    emissive: 0x000000,
    count: 8,
    speed: 0.02,
    letters: ["E","A","R","T","H"],
  },
  {
    id: 2,
    name: "Fire Meteors",
    geometry: "sphere",        // SphereGeometry
    color: 0xff6600,
    emissive: 0xff2200,
    count: 10,
    speed: 0.03,
    letters: ["F","I","R","E"],
  },
  // ... waves 3-5
];
```

### Codex System (Educational)
Every destroyed meteor has a chance to drop a letter:
- **Drop chance**: 40% + (wave × 10%)  
- **Sequential collection**: Letters collected in order to spell words
- **Word unlocks**: Completing "FIRE" unlocks Fireball spell, etc.
- **Definition readout**: Archive Spirit NPC reads and defines completed words

### Spell System
| Spell | Unlock Word | Gesture | Cooldown | Effect |
|-------|-------------|---------|----------|--------|
| Fireball | FIRE | Swipe up | 3s | Straight projectile, single target |
| Electric Charge | STORM | Palm push | 5s | AOE burst around player |
| Void Pulse | VOID | Circle gesture | 8s | Screen-clearing ring |
| Codex Seal | WARDEN | All 3 gestures | 30s | Ultimate boss damage |

---

## File Structure

```
ar/
├── android/
│   └── app/src/main/kotlin/com/example/ar/
│       ├── MainActivity.kt           # Flutter entry, scene registration
│       ├── CameraSpaceScanner.kt     # Custom environment analysis
│       ├── MyCameraView.kt           # CameraX + scanning integration
│       ├── GestureRecognizerHelper.kt  # MediaPipe Tasks wrapper
│       ├── MyCameraViewFactory.kt    # Platform view factory
│       └── OverlayView.kt            # Scanning visualization canvas
│
├── lib/
│   ├── main.dart                     # App entry, fullscreen
│   ├── landing_page.dart             # Story landing screen
│   └── my_camera_view.dart           # Pseudo-AR + tracking widget
│
├── android/app/src/main/assets/
│   └── gesture_recognizer.task      # MediaPipe model file
│
├── pubspec.yaml                      # Flutter dependencies
└── README.md                         # This file
```

---

## Build Instructions

### Prerequisites
- Flutter 3.11 or higher
- Android Studio (latest)
- Android SDK with API 24+
- ARCore-supported Android device

### Setup
```bash
# 1. Clone repository
git clone <repo-url>
cd ar

# 2. Install Flutter dependencies
flutter pub get

# 3. Verify ARCore availability
# Download "Google Play Services for AR" from Play Store

# 4. Run on device (AR requires physical device, not emulator)
flutter run
```

### ARCore Requirements Check
```bash
# Check if device supports ARCore
adb shell pm path com.google.ar.core

# Should output a path if ARCore is installed
# If not, install from Play Store
```

### Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Team

**University of Southeastern Philippines**  
**ICE 323 — Professional Elective 3**

| Name | Student ID | Role |
|------|------------|------|
| Crucio, John Paul S. | | Lead Developer / Game Design |
| Micaroz, Arthur Dale Enrique | | AR Implementation / 3D Assets |
| Renigado, Kyle Harvey C. | | Hand Tracking / Gesture System |

---

## License

Academic Project — University of Southeastern Philippines

---

## Acknowledgments

- **MediaPipe** for on-device hand tracking
- **CameraX** for reliable camera access
- **Flutter** for cross-platform UI framework

---

*AR Motion Smasher GDD v1.0 — April 2026*
