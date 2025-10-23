> English · [中文](./README.md)

# Video One RN

A React Native video streaming application built with BytePlus ReactNative Video SDK, providing best practices for short drama scenario development.

## 📱 Overview

Video One RN is a mobile application built with [BytePlus ReactNative VOD SDK](https://docs.byteplus.com/en/docs/byteplus-vod/docs-rn-player-quickstart) for short drama scenario playback, featuring complete video playback, user interaction capabilities, and content unlocking through advertisements.

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- Expo CLI
- iOS Simulator (for iOS development)
- Android Studio (for Android development)

### Installation Steps

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd video-one-rn
   ```

2. **Install dependencies**

   ```bash
   npm install
   # or
   yarn install
   ```

3. **Start the development server**

   ```bash
   npm start
   # or
   yarn start
   ```

4. **Run on specific platforms**

   ```bash
   # iOS
   npm run ios

   # Android
   npm run android
   ```

## 📁 Project Structure

```
Client/ReactNative/
├── app/                    # App screens (Expo Router)
│   ├── _layout.tsx         # Root layout
│   ├── index.tsx           # Home screen
│   ├── drama_channel.tsx   # Drama channel screen
│   ├── drama_player.tsx    # Video player screen
│   └── +not-found.tsx      # 404 screen
├── components/             # Reusable components
│   ├── player/             # Video player components
│   │   ├── VideoPlayer.tsx      # Main video player
│   │   ├── EpisodePlayer.tsx    # Episode player wrapper
│   │   ├── PlaybackControls.tsx # Playback control component
│   │   └── index.ts
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
│   │   └── src/            # Android source code
│   ├── build.gradle        # Project build configuration
│   ├── gradle/             # Gradle wrapper
│   ├── gradle.properties   # Gradle properties
│   ├── gradlew             # Gradle wrapper script (Unix)
│   ├── gradlew.bat         # Gradle wrapper script (Windows)
│   └── settings.gradle     # Gradle settings
├── ios/                    # iOS-specific files
│   ├── videoonern/         # iOS app target
│   │   ├── AppDelegate.swift
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
│   ├── withATSConfig.js    # ATS configuration plugin
│   ├── withLicense.js      # License file plugin
│   ├── withPodfileSources.js # Podfile sources plugin
│   └── xcodeUtils.js       # Xcode utilities
├── scripts/                # Build and utility scripts
│   └── reset-project.js    # Project reset script
├── app.json                # Expo app configuration
├── tsconfig.json           # TypeScript configuration
├── package.json            # npm package configuration
├── expo-env.d.ts           # Expo TypeScript definitions
├── eslint.config.js        # ESLint configuration
├── detection_tool.py       # Detection utility
├── LICENSE                 # License file
├── README.md               # English documentation
└── README-zh_CN.md         # Chinese documentation
```

## 🏗️ Technical Architecture

### Core Technologies

- **React Native**: Cross-platform mobile development framework
- **Expo**: Development platform and toolchain with rich APIs and components
- **TypeScript**: Type-safe JavaScript superset
- **Expo Router**: File-based routing system for simplified navigation management

### Architecture Design Patterns

1. **Componentized Architecture**: Components organized by functional modules for improved code reusability

   - `player/`: Video playback related components
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
# Development related
npm start              # Start Expo development server
npm run android        # Run on Android device/emulator
npm run ios           # Run on iOS device/simulator

# Code quality
npm run lint          # Run ESLint code checking

# Project maintenance
npm run reset-project # Reset project structure
```

### Development Environment Setup

1. **Install Expo CLI**

   ```bash
   npm install -g @expo/cli
   ```

2. **Configure development environment**

   - iOS: Install Xcode and iOS Simulator
   - Android: Install Android Studio and Android SDK

3. **Start the project**
   ```bash
   npm start
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
