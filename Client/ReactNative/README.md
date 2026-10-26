> English · [中文](./README.zh_CN.md)

# Video One RN

A React Native video streaming application built with BytePlus ReactNative Video SDK, providing best practices for short drama scenario development.

## 📱 Overview

Video One RN is a mobile application built with [BytePlus ReactNative VOD SDK](https://docs.byteplus.com/en/docs/byteplus-vod/docs-rn-player-quickstart) for short drama scenario playback, featuring complete video playback, user interaction capabilities, content unlocking through advertisements, and **screen casting** (Google Cast on Android, AirPlay on iOS).

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18.0.0
- Yarn (recommended) or npm
- Expo CLI (`npx expo`)
- Xcode (iOS) / Android Studio (Android)
- A physical device on the **same Wi‑Fi network** as your Cast receiver or AirPlay target (required to test casting)

### Installation Steps

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd video-one-rn
   ```

2. **Install dependencies**

   ```bash
   yarn install
   ```

3. **Generate native projects** (first run or after native dependency changes)

   ```bash
   yarn prebuild
   cd ios && pod install && cd ..
   ```

4. **Start the development server**

   ```bash
   yarn start
   ```

5. **Run on a device or emulator**

   ```bash
   # iOS (physical device recommended for AirPlay)
   yarn ios

   # Android (auto-writes node.binary for Gradle)
   yarn android
   ```

## 📁 Project Structure

```
video-one-rn/
├── app/                    # App screens (Expo Router)
│   ├── _layout.tsx         # Root layout
│   ├── index.tsx           # Home screen
│   ├── drama_channel.tsx   # Drama channel screen
│   ├── drama_player.tsx    # Video player screen
│   └── +not-found.tsx      # 404 screen
├── components/             # Reusable components
│   ├── player/             # Video player components
│   │   ├── VideoPlayer.tsx      # Main video player (local pause/resume during cast)
│   │   ├── EpisodePlayer.tsx    # Episode player wrapper (Cast button + overlay)
│   │   ├── PlaybackControls.tsx # Playback control component
│   │   └── index.ts
│   ├── cast/               # Screen casting (Cast / AirPlay)
│   │   ├── CastButton.tsx           # Platform cast trigger
│   │   ├── CastActiveOverlay.tsx    # Full-screen casting overlay
│   │   ├── CastStatusBar.tsx        # Slim casting status banner
│   │   ├── AirPlayRelay.ts          # iOS native AirPlay bridge
│   │   └── AirPlayRoutePickerView.tsx
│   ├── modals/             # Modal components
│   │   ├── EpisodeSelectorModal.tsx  # Episode selection modal
│   │   ├── VipUnlockModal.tsx        # VIP unlock modal
│   │   ├── UnlockMultipleModal.tsx   # Batch unlock modal
│   │   └── index.ts
│   ├── feed/               # Content feed components
│   │   ├── FeedCard.tsx              # Content card
│   │   ├── FeedInfoPanel.tsx         # Content info panel
│   │   ├── RecommendationOverlay.tsx # Recommendation overlay
│   │   └── index.ts
│   ├── ui/                 # UI components
│   │   ├── AdComponent.tsx              # Ad component
│   │   ├── LikeButton.tsx               # Like button
│   │   ├── EpisodeSelector.tsx          # Episode selector
│   │   ├── PlaybackSpeedSelector.tsx    # Playback speed selector
│   │   ├── LandscapeEpisodeSelector.tsx # Landscape episode selector
│   │   ├── LandscapeQualitySelector.tsx # Landscape quality selector
│   │   ├── LandscapeSpeedSelector.tsx   # Landscape speed selector
│   │   ├── HomeCard.tsx                 # Home card
│   │   └── index.ts
│   ├── shared/             # Shared components
│   │   ├── ThemedText.tsx     # Themed text component
│   │   ├── ThemedView.tsx     # Themed view component
│   │   ├── UserAvatar.tsx     # User avatar component
│   │   └── index.ts
│   ├── drama/              # Drama-related components
│   │   ├── DramaCarousel.tsx  # Drama carousel
│   │   ├── DramaCover.tsx     # Drama cover
│   │   ├── DramaList.tsx      # Drama list
│   │   └── index.ts
│   └── index.ts            # Component exports
├── services/               # API services
│   ├── api.ts              # Base API client
│   ├── dramaService.ts     # Drama data service
│   ├── unlockService.ts    # Content unlock service
│   └── userService.ts      # User management service
├── hooks/                  # Custom React hooks
│   ├── useCast.ts          # Unified Cast / AirPlay hook
│   ├── useColorScheme.ts   # Color theme hook
│   ├── useDramaChannel.ts  # Drama channel hook
│   └── useThemeColor.ts    # Theme color hook
├── utils/                  # Utility functions
│   ├── apiTestUtils.ts     # API testing utilities
│   ├── dramaUtils.ts       # Drama-related utilities
│   ├── imageUtils.ts       # Image handling utilities
│   └── playerConfig.ts     # Player configuration utilities
├── types/                  # TypeScript type definitions
│   └── drama.ts            # Drama-related types
├── constants/              # App constants
│   ├── Colors.ts           # Color definitions
│   └── HomeConstants.ts    # Home screen constants
├── assets/                 # Static assets
│   ├── images/             # Images and icons
│   │   ├── home/           # Home-related images
│   │   │   ├── 2x/         # 2x resolution images
│   │   │   ├── 3x/         # 3x resolution images
│   │   │   └── poster/     # Poster images
│   │   └── ...             # Other general images
│   ├── fonts/              # Custom fonts
│   │   └── SpaceMono-Regular.ttf
│   ├── minidrama/          # Drama-specific assets
│   │   ├── avatars/        # User avatars (20 files)
│   │   ├── common/         # Common icons and images
│   │   │   ├── 2x/         # 2x resolution icons
│   │   │   ├── 3x/         # 3x resolution icons
│   │   │   └── player/     # Player-specific icons
│   │   ├── licenses/       # License files
│   │   └── lotties/        # Lottie animations (like/unlike)
│   └── ttsdk.lic           # SDK license file
├── android/                # Android-specific files
│   ├── app/                # Android app module
│   │   ├── build.gradle    # App build configuration
│   │   └── src/main/java/.../CastOptionsProvider.kt  # Google Cast options
│   ├── node.gradle         # Node path resolution for Gradle
│   ├── build.gradle        # Project build configuration
│   ├── gradle/             # Gradle wrapper
│   ├── gradle.properties   # Gradle properties
│   ├── gradlew             # Gradle wrapper script (Unix)
│   ├── gradlew.bat         # Gradle wrapper script (Windows)
│   └── settings.gradle     # Gradle settings
├── ios/                    # iOS-specific files
│   ├── videoonern/         # iOS app target
│   │   ├── AppDelegate.swift
│   │   ├── AirPlayRelay.m              # AVPlayer relay for AirPlay
│   │   ├── AirPlayRoutePickerViewManager.m
│   │   ├── Images.xcassets/
│   │   ├── Info.plist
│   │   ├── PrivacyInfo.xcprivacy
│   │   └── SplashScreen.storyboard
│   ├── videoonern.xcodeproj/     # Xcode project
│   ├── videoonern.xcworkspace/   # Xcode workspace
│   ├── Podfile             # CocoaPods dependencies
│   ├── Podfile.lock        # CocoaPods lock file
│   └── Pods/               # CocoaPods dependencies
├── plugins/                # Expo config plugins
│   ├── withLicense.js      # License file plugin
│   ├── withPodfileSources.js # Podfile sources plugin
│   ├── withGoogleCast.js   # Google Cast (Android) config plugin
│   └── xcodeUtils.js       # Xcode utilities
├── scripts/                # Build and utility scripts
│   ├── reset-project.js    # Project reset script
│   └── setup-android-node.sh  # Writes node.binary for Android Gradle
├── babel.config.js         # Babel (react-native-worklets plugin for Reanimated v4)
├── metro.config.js         # Metro bundler configuration
├── app.json                # Expo app configuration
├── tsconfig.json           # TypeScript configuration
├── package.json            # Package configuration
├── yarn.lock               # Yarn lockfile
├── expo-env.d.ts           # Expo TypeScript definitions
├── eslint.config.js        # ESLint configuration
├── detection_tool.py       # Detection utility
├── LICENSE                 # License file
├── README.md               # English documentation
└── README.zh_CN.md         # Chinese documentation
```

## 🏗️ Technical Architecture

### Core Technologies

- **React Native 0.83** + **Expo SDK 55**: Cross-platform development with the New Architecture enabled
- **TypeScript**: Type-safe JavaScript superset
- **Expo Router**: File-based routing system for simplified navigation management
- **@byteplus/react-native-vod-player**: BytePlus VOD playback SDK
- **react-native-google-cast** (Android): Google Cast device discovery and remote playback
- **Custom native AirPlay relay** (iOS): `AVRoutePickerView` + `AVPlayer` relay with progress sync back to the local player

### Architecture Design Patterns

1. **Componentized Architecture**: Components organized by functional modules for improved code reusability

   - `player/`: Video playback related components
   - `cast/`: Screen casting UI and native bridges
   - `modals/`: Modal components
   - `feed/`: Content feed components
   - `ui/`: General UI components
   - `shared/`: Shared components
   - `drama/`: Drama-related components

2. **Service Layer Separation**: API services separated by business domain

   - `dramaService.ts`: Drama data management
   - `unlockService.ts`: Content unlock service
   - `userService.ts`: User management service

3. **Custom Hooks**: Encapsulate reusable business logic

   - `useCast.ts`: Unified Cast (Android) / AirPlay (iOS) session and playback control
   - `useDramaChannel.ts`: Drama channel data management
   - `useColorScheme.ts`: Theme color management

4. **Type Safety**: Comprehensive TypeScript type definitions
   - Complete interface definitions
   - Strict type checking
   - Excellent development experience

## 🎯 Features

### 🎬 Video Playback Features

- **High-quality video streaming**: Support for multiple quality options (720p, 480p, etc.)
- **Playback controls**: Play/pause, progress bar, volume control
- **Multi-speed playback**: Support for playback speeds from 0.5x to 2.0x
- **Landscape/portrait switching**: Automatic screen orientation adaptation with different control interfaces
- **Progress management**: Support for drag-to-seek and playback position memory
- **Video caching**: Support for video preloading with automatic strategies

### 📺 Screen Casting

- **Android — Google Cast**: Discover Chromecast / Cast-enabled devices on the local network, load the current episode URL to the default receiver (`CC1AD845`), and pause local playback while casting
- **iOS — AirPlay**: System route picker (`AVRoutePickerView`) plus a native `AirPlayRelay` that plays the stream on the AirPlay target and reports progress for seamless local resume
- **Cast UI**: `CastButton` in the player chrome, `CastActiveOverlay` while casting, optional `CastStatusBar`
- **Episode switching**: `updateCastMedia` updates the remote source when the user changes episodes during an active Cast session (Android)

### 👥 User Interaction Features

- **Like system**: Support for like/unlike with real-time count updates
- **Comment functionality**: User comments and interactions
- **Haptic feedback**: Provides haptic feedback to enhance user experience

### 💰 Monetization Features

- **Ad-based unlocking**: Watch ads to unlock paid content
- **VIP subscription**: Pay to unlock all content
- **Batch unlocking**: Unlock multiple episodes at once

### 📱 Content Management

- **Drama carousel**: Home page drama recommendation carousel
- **Content lists**: Categorized drama content display
- **Recommendation system**: Intelligent recommendations based on user behavior

## 🔧 Development Guide

### Available Script Commands

```bash
# Development
yarn start              # Start Expo dev server (clears cache)
yarn prebuild           # Regenerate android/ and ios/ (expo prebuild --clean)
yarn android            # Setup node.binary + run on Android
yarn ios                # Run on iOS device

# Release builds
yarn android:release    # Assemble Android release APK/AAB
yarn ios:release        # Run iOS Release on device
yarn ios:archive        # Xcode archive (Release, iphoneos)

# Code quality
yarn lint               # Run ESLint

# Project maintenance
yarn reset-project      # Reset project structure
```

### Development Environment Setup

1. **Configure development environment**

   - iOS: Xcode, CocoaPods (`pod install` under `ios/`)
   - Android: Android Studio, JDK 17+, ensure `node` is on your `PATH` (or set `NODE_BINARY`)

2. **Start the project**
   ```bash
   yarn start
   ```

3. **Native rebuild after plugin or SDK changes**
   ```bash
   yarn prebuild
   cd ios && pod install && cd ..
   ```

## 📱 Platform Support

- **iOS**: Support for iOS 11.0 and above
- **Android**: Support for Android API level 23 and above

## 🔐 Configuration Instructions

### Environment Variable Configuration

1. **API Configuration**: Configure API endpoints in `services/api.ts`

```typescript
const API_BASE_URL = "https://your-api-domain.com";
```

2. **Video Player Configuration**: Configure video player related parameters

```typescript
// Configure player parameters in VideoPlayer component
```

3. **Monetization Configuration**: Configure ad and payment related parameters
   ```typescript
   // Configure unlock parameters in unlockService
   ```

### Screen Casting Configuration

Casting is wired through Expo config plugins and native modules. Most defaults work out of the box.

| Platform | Mechanism | Key files |
| -------- | --------- | --------- |
| Android | Google Cast SDK via `react-native-google-cast` | `plugins/withGoogleCast.js`, `CastOptionsProvider.kt` |
| iOS | AirPlay route picker + `AirPlayRelay` native module | `ios/videoonern/AirPlayRelay.m`, `app.json` → `ios.infoPlist` |

**Android Cast receiver App ID** — edit `CAST_APP_ID` in `android/app/src/main/java/com/byteplus/videoone/rn/CastOptionsProvider.kt`. The default `CC1AD845` is Google's stock media receiver (no custom registration required).

**iOS local network** — `app.json` declares `NSLocalNetworkUsageDescription` and Bonjour services (`_airplay._tcp`, `_googlecast._tcp`, `_CC1AD845._googlecast._tcp`) so Cast/AirPlay devices can be discovered on the LAN.

**Gradle + Node** — `yarn android` runs `scripts/setup-android-node.sh`, which writes `node.binary` into `android/local.properties` for Gradle and Android Studio builds.

### Build Configuration

- **iOS Configuration**: Configure iOS-specific settings in `ios/` directory
- **Android Configuration**: Configure Android-specific settings in `android/` directory
- **Expo Configuration**: Configure Expo-related settings in `app.json`

## 🚀 Deployment Guide

### Development Environment Deployment

1. **Local Development**

   ```bash
   npm start
   ```

2. **Device Debugging**
   - Install Expo Go app
   - Scan QR code to connect to development server

### Production Environment Deployment

1. **Build Application**

```bash
   expo build:android
   expo build:ios
```

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Welcome to submit Issues and Pull Requests to improve the project.

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

For questions or suggestions, please contact us through:

- Submit Issue: [GitHub Issues](https://github.com/your-repo/issues)
- Email: your-email@example.com

---

**Note**: This project is for learning and research purposes only. Please comply with relevant laws and regulations.
