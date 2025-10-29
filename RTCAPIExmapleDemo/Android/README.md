# API Example Android

BytePlus RTC provides an open-source sample project named API Example Demo. After obtaining this project,
you can follow this document to get it running and experience real-time audio and video features。
you can also learn about best practices by reading the code。

## Prerequisites

> [!NOTE]
> It is recommended to use a real device for debugging, as some functions may not be accessible on an emulator. For the real device connection guide, please refer to[Run the application on a hardware device](https://developer.android.com/studio/run/device?hl=zh-cn)。

Before starting the integration of the RTC SDK, please ensure that the following requirements are met：

- Android Studio Arctic Fox | 2020.3.1 or a later version（This article uses Android Studio Giraffe | Version 2022.3.1）
- An Android real device or emulator running Android 4.4 or a later version
-The Android device and the development computer can access the Internet normally
- Activate the Real-Time Audio and Video Service on the [console]([https://console.byteplus.com/auth/login])， You need to obtain the AppID and AppKey from the console to run the project successfully


## Obtain the Sample Project
You can obtain the sample project from GitHub: []

Android The directory structure of the sample project is as follows：

```
.
├── BaseActivity.java
├── MainActivity.java
├── Utils
├── common
└── examples
    ├── QuickStartActivity.java              
    ├── AudioMixing
    │   ├── AudioEffectMixingActivity.java   
    │   ├── AudioMediaMixingActivity.java    
    │   └── AudioMixingActivity.java
    ├── CDNStreamActivity.java               
    ├── CrossRoomPKActivity.java             
    ├── MultiRoomActivity.java               
    ├── PictureInPicture                     
    ├── RawAudioDataActivity.java            [README.md](../iOS/README.md)
    ├── ThirdBeauty
    │   ├── Fubeauty                         
    │   ├── ThirdBeautyActivity.java
    │   └── byteBeauty                       
    ├── VideoConfigActivity.java             
    └── VoiceEffectActivity.java            
```

## Configure the Sample Project

1. Activate the BytePlus RTC service, create a RTC app and obtain the AppId and AppKey from the [console](https://docs.byteplus.com/en/docs/byteplus-rtc/docs-69865)，
	Please fill in the correct information for `APP_ID` and `APP_KEY` in the file `Android/APIExample/app/src/main/java/rtc/volcengine/apiexample/common/Constants.java`.
	Otherwise, the compilation will fail.
	![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_204f74dd1f10a3850e3707a4d6b42c1c.png)
2. (Optional) In the sample project, the intelligent beautification effects and FaceUnity Beauty functions require separate filling in of authentication information.
    Not filling in the authentication information will not affect the compilation and operation of the Demo, but you will not be able to experience the relevant functions.
	- [Beauty Effects](https://www.byteplus.com/en/product/effects)
	- [FaceUnity beauty](https://www.faceunity.com/developer/)：Please contact the FaceUnity Beauty Business Team at marketing@faceunity.com to obtain the certificate, 
      and use the obtained certificate to replace the `Android/APIExample/faceunity/src/main/java/com/faceunity/nama` file under the path `authpack.java`.

## Compile and run the sample project

1. Enable the Developer options on your Android device, turn on USB Debugging, connect the Android device to your computer using a USB cable, and select your Android device from the Android device options. 
   For details, refer to [Run apps on a hardware device](https://developer.android.com/studio/run/device?hl=zh-cn).
2. Click **Sync Project with Gradle Files** in the upper right corner of the Android Studio window (or use the **Shift ⇧** + **Command ⌘** + **O** keyboard shortcut) to sync the project and fetch project dependencies.
3. Click **Run 'app'** in the upper right corner of the Android Studio window (or use the **Control ⌃** + **R** keyboard shortcut) to start compilation.
4. After the compilation is successful, the API Example app will appear on your Android device. Select to enable camera and microphone permissions in the pop-up window. The app interface is as follows:
    ![](https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_2ed0da872b31a35b08f7c73bf4eadb17.png)
