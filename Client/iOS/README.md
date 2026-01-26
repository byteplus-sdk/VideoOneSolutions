The BytePlus VideoOne demo project utilizes multiple BytePlus media SDKs along with BytePlus video cloud services to provide a set of demos for industry-specific scenarios.

For detailed instructions on how to run the entire demo, refer to [Running the demo (iOS)](https://docs.byteplus.com/en/byteplus-vos/docs/running-the-demo-ios-).

Note: The demo requires setting AppId and License to run successfully.

# Directory Structure About VoD In iOS

```plain
├── VideoOneSolutions 
    ├── Client
        ├── iOS
            ├── Component
                ├── App                // App entry
                ├── AppConfig          // App configs
                ├── LoginKit           // Login kit
                ├── MiniDrama          // Short drama scene
                ├── ToolKit            // Tool kit
                ├── VideoPlaybackEdit  // video playback(short, feed and long videos) scene
                ├── VodSingleFunction  // basic video functions
                ...
        └── Android
```

 For the detailed instructions about the short drama scene, refer to [Running the short drama demo(iOS)](https://docs.byteplus.com/en/docs/byteplus-vos/overview-of-short-drama-videos).

## App
The App component is the entry point of the demo app. If you don't need the entry part of the demo, you can delete it and directly copy the page of the specific function, such as `MiniDramaMainViewController`.

## AppConfig
We maintain the AppId, BundleId, and license used by the demo in the AppConfig module. If you integrate the entire demo, you only need to fill in the information used for testing here. If you only integrate some functions in the demo, you can delete the module and manage the license and other information yourself.

## LoginKit
This is the login module in the demo. You can choose whether to keep it or not. It does not involve VoD related functions.

## MiniDrama
This module contains the code for the short drama scene, including the recommendation page, details page, paid unlock function, etc. The following is the directory structure related to the short drama:

```plain
├── MiniDrama 
    ├── Resources
    ├── Classes
        ├── Entry
            ├── MiniDrama.m
        ├── Main
            ├── MiniDramaMainViewController.m
            ├── CommonUI
            ├── Data
                ├── Model
                └── Network
            ├── MiniDramaChannelPage
            ├── MiniDramaHomePage
            └── PlayerModules
        └── Player
```

- `MiniDrama.m`: It contains BytePlus VOD Player initialization.
- `MiniDramaMainViewController.m`: It is the main controller of the short drama scene.
- `CommonUI`: It contains few basic UI components, such as UIButton, UIViewController for short drama scene.
- `Model`: It contains the data model of the short drama scene, such as dama info, episode info, etc.
- `Network`: It contains network interfaces in the short drama scene.
- `MiniDramaChannelPage` & `MiniDramaHomePage`: This two folders contain the specific UI controllers about the short drama scene, such as the recommend controller, short drama details controller, etc.
- `PlayerModules`: It contains some play controls for the short drama scene, such as play button, double speed, etc.
- `Player`: It contains the basic components for VoD. You can write your own module code(such as `PlayerModules`) based on it.

---

For detailed instructions, you can refer to [Running the short drama demo(iOS)](https://docs.byteplus.com/en/docs/byteplus-vos/overview-of-short-drama-videos).

## ToolKit
This module includes common tools for multiple solutions, including VoD, Media Live, RTC, etc. You can just keep the 'Common' and 'VodPlayer' subspecs in the podspec file.

## VideoPlaybackEdit
This module contains different video playback scenes: ShortVideo, FeedVideo and LongVideo. Each folder contains a different UI design. Besides, this module contains some supporting functions for video model and network.

## VodSingleFunction
This module shows some other playback-related functions:
- Video playback demonstration;
- Anti-screen recording/Anti-screen shoting;
- Smart subtitles;
- Play video lists;
