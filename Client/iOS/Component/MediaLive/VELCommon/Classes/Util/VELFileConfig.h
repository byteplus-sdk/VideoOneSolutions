// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface VELFileConfig : NSObject
@property (nonatomic, assign, readonly) NSTimeInterval interval;
@property (nonatomic, assign, readonly) int packetSize;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
- (BOOL)isValid;

@end
typedef NS_ENUM(NSInteger, VELVideoFileType) {
    VELVideoFileType_UnKnown,
    VELVideoFileType_BGRA,
    VELVideoFileType_NV12,
    VELVideoFileType_NV21,
    VELVideoFileType_YUV
};

typedef NS_ENUM(NSInteger, VELVideoFileConvertType) {
    VELVideoFileConvertTypeUnKnown,
    VELVideoFileConvertTypeTextureID = 1,
    VELVideoFileConvertTypeEncodeData,
    VELVideoFileConvertTypePixelBuffer,
    VELVideoFileConvertTypeSampleBuffer,
};
@interface VELVideoFileConfig : VELFileConfig
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) VELVideoFileType fileType;
@property (nonatomic, copy, readonly) NSString *fileTypeDes;
@property (nonatomic, assign) VELVideoFileConvertType convertType;
@end
typedef NS_ENUM(NSInteger, VELAudioFileType) {
    VELAudioFileType_UnKnown,
    VELAudioFileType_PCM,
};

@interface VELAudioFileConfig : VELFileConfig
@property (nonatomic, assign) int readCountPerSecond;
@property (nonatomic, assign) int sampleRate;
@property (nonatomic, assign) int bitDepth;
@property (nonatomic, assign) int channels;
@property (nonatomic, assign) VELAudioFileType fileType;

@property (nonatomic, assign) BOOL playable;
@end

NS_ASSUME_NONNULL_END
