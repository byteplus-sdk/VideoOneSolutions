# API Example iOS

BytePlus RTC provides an open-source sample project named API Example Demo. After obtaining this project, 
you can follow this document to get it running and experience real-time audio and video features。
you can also learn about best practices by reading the code。

## Prerequisites

- A macOS development computer with normal internet access
- Xcode 14.1 or later
- An Apple Developer account
- A physical iOS device running iOS 11.0 or later, with normal internet access
- Activate the Real-Time Audio and Video Service on the [console]([https://console.byteplus.com/auth/login])， You need to obtain the AppID and AppKey from the console to run the project successfully

## Obtain the Sample Project

You can obtain the sample project from GitHub: []

iOS The directory structure of the sample project is as follows：

```
.
├── ApiExample
│   ├── ApiExample
│   │   ├── ApiExample-Bridging-Header.h
│   │   ├── AppDelegate.swift
│   │   ├── Assets.xcassets
│   │   ├── QuickStart                 
│   │   ├── AudioManager
│   │   │   ├── AudioEffectMixing      
│   │   │   ├── AudioMediaMixing      
│   │   │   ├── AudioRawData           
│   │   │   └── SoundEffects           
│   │   ├── AudioVideoTransmission
│   │   │   └── CrossRoomPK           
│   │   ├── ImportantComponents
│   │   │   └── Beauty
│   │   │   │   ├── BeautyViewController.swift
│   │   │   │   ├── FaceUnityBeauty    
│   │   │   │   └── VolcBeauty         
│   │   │   └── PullRTMP 			   
│   │   ├── LiveManager
│   │   │   └── PushCDN                
│   │   ├── RoomManager
│   │   │   └── MutiRoom               
│   │   ├── SEI						   
│   │   ├── VideoManager
│   │   │   ├── CommonConfig           
│   │   │   ├── PictureInPicture       
│   │   │   └── VideoRotation          
│   │   ├── Base.lproj
│   │   ├── Common
│   │   ├── Config.swift
│   │   ├── Info.plist
│   │   ├── TokenGenerator
│   │   └── ViewController.swift
│   ├── ApiExample.xcodeproj
│   ├── Podfile
│   └── bdaudioeffect.framework
└── README.md
```

## Configure the Sample Project

1. Under the `iOS/ApiExample` directory, execute the command pod install to install the project dependencies.

2. Open `ApiExample.xcworkspace` using XCode, obtain the AppID and AppKey from the console, and fill them into the kAppID and kAppKey fields in `ApiExample/Config.swift` respectively. Please fill in the information correctly; otherwise, the compilation will fail.
	![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_49fda580e4ae64d34c1f1306e2e6defe.png)

3. Configure the Developer Certificate：
    1. Select the ApiExample project in the left navigation bar of Xcode, navigate to the Signing & Capabilities tab, and check Automatically manage signing to generate the certificate automatically. You can also configure it manually through the [Apple Official Website]([https://developer.apple.com/])and download the certificate.
    2. Select `Personal Team` for **Team**
    3. **Bundle Identifier** `rtc.vertcdemo.apiexample.dev` has already been registered; please modify it to another valid Bundle ID.
	![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_18711cf35916194388ebdce2790ec8de.png)
	
4. (Optional) The intelligent beautification effects and FaceUnity beauty features in the sample project require separate filling in of authentication information. Not filling in the authentication information will not affect the compilation and operation of the Demo, but you will not be able to experience the relevant features.
	- [Beauty Effects](https://www.byteplus.com/en/product/effects)：
		1. Please contact the [Intelligent Beauty Effects Business Team](https://docs.byteplus.com/en/docs/effects/docs-license-guide-a22f3127)to obtain the effect certificate and material resource files.
        2. Place the obtained certificate and material resource files into the `ApiExample/ImportantComponents/Beauty/VolcBeauty/resource` folder, then checked `Copy items if needed`.
			![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_64d691a20a1deeabeddaa486f1beb1d6.png)
        3. Obtain the filename of the certificate file from `LicenseBag.bundle`, and fill it into `CVLicenseName` in `ApiExample/Config.swift`. For example: `let CVLicenseName = "rtc_test_vertc.veRTCDemo.ios_4.4.2_633.licbag"`. Please note that the package name corresponding to the certificate must be consistent with the Bundle Identifier you set in Step 3.
			
	- [FaceUnity beauty](https://www.faceunity.com/developer/)：Please contact the FaceUnity Beauty Business Team at marketing@faceunity.com to obtain the certificate, and use the obtained certificate to replace the `authpack.h` file under the path `ApiExample/ImportantComponents/Beauty/FaceUnityBeauty`.

## Compile and run the sample project

> [!NOTE]
> If you haven't trusted the developer yet, follow the prompts in Xcode to open **Settings** on your iOS device, select **General** > **VPN & Device Management**, and tap to trust the developer under **Developer App**. 

1. Connect and select your iOS physical device in Xcode, then click the Run button in the upper-left corner of the Xcode window (or use the **Command ⌘** + **R** keyboard shortcut).

2. When opening the Demo app on your iOS device, select "Allow" in the pop-up windows to grant camera and microphone permissions. The app interface is as follows：
    ![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_71e860a6953009adc11112a8dd5bc873.png)
