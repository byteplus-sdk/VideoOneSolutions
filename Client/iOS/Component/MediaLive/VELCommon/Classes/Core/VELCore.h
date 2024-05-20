// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-umbrella"



#ifndef VEL_TTSDK_CORE_MODULE_ENABLE

#define VEL_TTSDK_CORE_MODULE_ENABLE 1
#if __has_include("TTSDKManager.h")
#   import "TTSDKManager.h"
#elif __has_include(<TTSDK/TTSDKManager.h>)
#   import <TTSDK/TTSDKManager.h>
#elif __has_include(<TTSDKFramework/TTSDKManager.h>)
#   import <TTSDKFramework/TTSDKManager.h>
#elif __has_include(<TTSDKPullFramework/TTSDKManager.h>)
#   import <TTSDKPullFramework/TTSDKManager.h>
#elif __has_include(<TTSDKRTMPullFramework/TTSDKManager.h>)
#   import <TTSDKRTMPullFramework/TTSDKManager.h>
#elif __has_include(<TTSDKBasePullFramework/TTSDKManager.h>)
#   import <TTSDKBasePullFramework/TTSDKManager.h>
#elif __has_include(<TTSDKPushFramework/TTSDKManager.h>)
#   import <TTSDKPushFramework/TTSDKManager.h>
#elif __has_include(<TTSDKRtmPushFramework/TTSDKManager.h>)
#   import <TTSDKRtmPushFramework/TTSDKManager.h>
#else
#   undef VEL_TTSDK_CORE_MODULE_ENABLE
#endif
#endif



#ifndef VEL_PULL_MODULE_NEW_API_ENABLE
#define VEL_PULL_MODULE_NEW_API_ENABLE 1
#if __has_include("VeLivePlayerStream.h")
#   import "TTVideoLive.h"
#   import "VeLivePlayerStream.h"
#   import "VeLivePlayerStreamData.h"
#   import "VeLivePlayerData.h"
#   import "VeLivePlayer.h"
#   import "VeLivePlayerError.h"
#elif __has_include(<TTSDK/VeLivePlayerStream.h>)
#   import <TTSDK/TTVideoLive.h>
#   import <TTSDK/VeLivePlayerStream.h>
#   import <TTSDK/VeLivePlayerStreamData.h>
#   import <TTSDK/VeLivePlayerData.h>
#   import <TTSDK/VeLivePlayer.h>
#   import <TTSDK/VeLivePlayerError.h>
#elif __has_include(<TTSDKFramework/VeLivePlayerStream.h>)
#   import <TTSDKFramework/TTVideoLive.h>
#   import <TTSDKFramework/VeLivePlayerStream.h>
#   import <TTSDKFramework/VeLivePlayerStreamData.h>
#   import <TTSDKFramework/VeLivePlayerData.h>
#   import <TTSDKFramework/VeLivePlayer.h>
#   import <TTSDKFramework/VeLivePlayerError.h>
#elif __has_include(<TTSDKPullFramework/VeLivePlayerStream.h>)
#   import <TTSDKPullFramework/TTVideoLive.h>
#   import <TTSDKPullFramework/VeLivePlayerStream.h>
#   import <TTSDKPullFramework/VeLivePlayerStreamData.h>
#   import <TTSDKPullFramework/VeLivePlayerData.h>
#   import <TTSDKPullFramework/VeLivePlayer.h>
#   import <TTSDKPullFramework/VeLivePlayerError.h>
#elif __has_include(<TTSDKRTMPullFramework/VeLivePlayerStream.h>)
#   import <TTSDKRTMPullFramework/TTVideoLive.h>
#   import <TTSDKRTMPullFramework/VeLivePlayerStream.h>
#   import <TTSDKRTMPullFramework/VeLivePlayerStreamData.h>
#   import <TTSDKRTMPullFramework/VeLivePlayerData.h>
#   import <TTSDKRTMPullFramework/VeLivePlayer.h>
#   import <TTSDKRTMPullFramework/VeLivePlayerError.h>
#elif __has_include(<TTSDKBasePullFramework/VeLivePlayerStream.h>)
#   import <TTSDKBasePullFramework/TTVideoLive.h>
#   import <TTSDKBasePullFramework/VeLivePlayerStream.h>
#   import <TTSDKBasePullFramework/VeLivePlayerStreamData.h>
#   import <TTSDKBasePullFramework/VeLivePlayerData.h>
#   import <TTSDKBasePullFramework/VeLivePlayer.h>
#   import <TTSDKBasePullFramework/VeLivePlayerError.h>
#else
#   undef VEL_PULL_MODULE_NEW_API_ENABLE
#endif

#endif

#ifndef VEL_PUSH_MODULE_NEW_API_ENABLE
#define VEL_PUSH_MODULE_NEW_API_ENABLE 1
#if __has_include("VeLivePusher.h")
#   import "VeLivePusher.h"
#   import "VeLivePusher+ScreenCapture.h"
#   import "VeLiveMixerManager.h"
#   import "VeLiveDeviceManager.h"
#   import "VeLiveMediaPlayer.h"
#   import "VeLivePusherConfiguration.h"
#   import "VeLivePusherDef.h"
#   import "VeLivePusherObserver.h"
#   import "VeLiveVideoEffectManager.h"
#elif __has_include(<TTSDK/VeLivePusher.h>)
#   import <TTSDK/VeLivePusher.h>
#   import <TTSDK/VeLivePusher+ScreenCapture.h>
#   import <TTSDK/VeLiveMixerManager.h>
#   import <TTSDK/VeLiveDeviceManager.h>
#   import <TTSDK/VeLiveMediaPlayer.h>
#   import <TTSDK/VeLivePusherConfiguration.h>
#   import <TTSDK/VeLivePusherDef.h>
#   import <TTSDK/VeLivePusherObserver.h>
#   import <TTSDK/VeLiveVideoEffectManager.h>
#elif __has_include(<TTSDKFramework/VeLivePusher.h>)
#   import <TTSDKFramework/VeLivePusher.h>
#   import <TTSDKFramework/VeLiveMixerManager.h>
#   import <TTSDKFramework/VeLiveDeviceManager.h>
#   import <TTSDKFramework/VeLiveMediaPlayer.h>
#   import <TTSDKFramework/VeLivePusherConfiguration.h>
#   import <TTSDKFramework/VeLivePusherDef.h>
#   import <TTSDKFramework/VeLivePusherObserver.h>
#   import <TTSDKFramework/VeLiveVideoEffectManager.h>
#elif __has_include(<TTSDKPushFramework/VeLivePusher.h>)
#   import <TTSDKPushFramework/VeLivePusher.h>
#   import <TTSDKPushFramework/VeLiveMixerManager.h>
#   import <TTSDKPushFramework/VeLiveDeviceManager.h>
#   import <TTSDKPushFramework/VeLiveMediaPlayer.h>
#   import <TTSDKPushFramework/VeLivePusherConfiguration.h>
#   import <TTSDKPushFramework/VeLivePusherDef.h>
#   import <TTSDKPushFramework/VeLivePusherObserver.h>
#   import <TTSDKPushFramework/VeLiveVideoEffectManager.h>
#elif __has_include(<TTSDKRTMPushFramework/VeLivePusher.h>)
#   import <TTSDKRTMPushFramework/VeLivePusher.h>
#   import <TTSDKRTMPushFramework/VeLiveMixerManager.h>
#   import <TTSDKRTMPushFramework/VeLiveDeviceManager.h>
#   import <TTSDKRTMPushFramework/VeLiveMediaPlayer.h>
#   import <TTSDKRTMPushFramework/VeLivePusherConfiguration.h>
#   import <TTSDKRTMPushFramework/VeLivePusherDef.h>
#   import <TTSDKRTMPushFramework/VeLivePusherObserver.h>
#   import <TTSDKRTMPushFramework/VeLiveVideoEffectManager.h>
#else
#   undef VEL_PUSH_MODULE_NEW_API_ENABLE
#endif
#endif

#ifndef VEL_TTSDK_EFFECT_MODULE_ENABLE
#define VEL_TTSDK_EFFECT_MODULE_ENABLE 1
#if __has_include("TTSDKEffectManager.h")
#   import "TTSDKEffectManager.h"
#elif __has_include(<TTSDK/TTSDKEffectManager.h>)
#   import <TTSDK/TTSDKEffectManager.h>
#elif __has_include(<TTSDKFramework/TTSDKEffectManager.h>)
#   import <TTSDKFramework/TTSDKEffectManager.h>
#elif __has_include(<TTSDKPushFramework/TTSDKEffectManager.h>)
#   import <TTSDKPushFramework/TTSDKEffectManager.h>
#elif __has_include(<TTSDKRTMPushFramework/TTSDKEffectManager.h>)
#   import <TTSDKRTMPushFramework/TTSDKEffectManager.h>
#else
#   undef VEL_TTSDK_EFFECT_MODULE_ENABLE
#endif
#endif


#pragma clang diagnostic pop
