// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <MediaLive/VELCommon.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELFileTool : NSObject
+ (VELAudioFileConfig *)getOrCreateAudioFileWithType:(VELAudioFileType)fileType;
+ (VELAudioFileConfig *)getOrCreateAudioFileWithName:(NSString *)fileName;
+ (VELVideoFileConfig *)getOrCreateVideoFileWithType:(VELVideoFileType)fileType;
+ (void)getAudioFileWithConfig:(VELAudioFileConfig *)config inView:(UIView *)inView completion:(void (^)(VELAudioFileConfig *config))completion;
+ (void)getVideoFileWithConfig:(VELVideoFileConfig *)config inView:(UIView *)inView completion:(void (^)(VELVideoFileConfig *config))completion;
+ (void)selectAudioFile:(VELAudioFileType)fileType fromFileAppInView:(UIView *)inView completion:(void (^)(VELAudioFileConfig *config))completion;
+ (void)selectVideoFile:(VELVideoFileType)fileType fromFileAppInView:(UIView *)inView completion:(void (^)(VELVideoFileConfig *config))completion;
@end

NS_ASSUME_NONNULL_END
