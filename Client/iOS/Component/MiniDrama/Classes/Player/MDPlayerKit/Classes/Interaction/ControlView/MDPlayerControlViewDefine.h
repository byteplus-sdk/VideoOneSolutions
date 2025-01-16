//
//  MDPlayerControlViewDefine.h
//  MDPlayerKit
//

#ifndef MDPlayerControlViewDefine_h
#define MDPlayerControlViewDefine_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MDPlayerControlViewType) {
    MDPlayerControlViewType_Underlay     = 11,
    MDPlayerControlViewType_Playback     = 12,
    MDPlayerControlViewType_PlaybackLock = 13,
    MDPlayerControlViewType_Overlay      = 14,
};

typedef NS_OPTIONS(NSUInteger, MDPlayerControlViewArea) {
    MDPlayerControlViewAreaNone        = 0,
    MDPlayerControlViewAreaTop         = 1 << 0,
    MDPlayerControlViewAreaLeft        = 1 << 1,
    MDPlayerControlViewAreaBottom      = 1 << 2,
    MDPlayerControlViewAreaRight       = 1 << 3,
    MDPlayerControlViewAreaCenter      = 1 << 4,
};

#endif /* MDPlayerControlViewDefine_h */
