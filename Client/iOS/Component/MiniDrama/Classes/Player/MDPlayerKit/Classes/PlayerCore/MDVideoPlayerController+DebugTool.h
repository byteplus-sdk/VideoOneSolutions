//
//  MDVideoPlayerController+DebugTool.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/6.
//

#import "MDVideoPlayerController.h"
#import <TTSDK/TTVideoEngineDebugTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (DebugTool)

@property (nonatomic, strong) TTVideoEngineDebugTools *videoEngineDebugTool; // debug tool

- (void)showDebugViewInView:(UIView *)hudView;

- (void)removeDebugTool;

+ (NSString *)deviceID;

@end

NS_ASSUME_NONNULL_END
