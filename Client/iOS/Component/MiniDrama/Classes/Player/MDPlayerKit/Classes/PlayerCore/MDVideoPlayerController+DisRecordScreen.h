//
//  MDVideoPlayerController+DisRecordScreen.h
//  MDPlayerKit
//
//  Created by zyw on 2024/4/18.
//

#import "MDVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (DIsRecordScreen)

- (void)registerScreenCapturedDidChangeNotification;

- (void)unregisterScreenCaptureDidChangeNotification;

@end

NS_ASSUME_NONNULL_END
