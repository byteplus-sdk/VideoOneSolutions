//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
@class LiveMediaComponent;

typedef NS_ENUM(NSInteger, LiveMediaStatus) {
    LiveMediaStatusHost,
    LiveMediaStatusGuests,
};

NS_ASSUME_NONNULL_BEGIN

@protocol LiveMediaComponentDelegate <NSObject>

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
           clickCancel:(BOOL)isClick;

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
       clickDisconnect:(BOOL)isClick;

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
       clickStreamInfo:(BOOL)isClick;

- (void)mediaComponent:(LiveMediaComponent *)mediaComponent
          toggleCamera:(BOOL)cameraOn;

@end

@interface LiveMediaComponent : NSObject

@property (nonatomic, weak) id<LiveMediaComponentDelegate> delegate;

- (void)show:(LiveMediaStatus)status
    userModel:(LiveUserModel *)userModel;

- (void)close;

@end

NS_ASSUME_NONNULL_END
