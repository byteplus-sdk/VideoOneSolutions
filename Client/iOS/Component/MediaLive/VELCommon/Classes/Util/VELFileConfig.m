// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFileConfig.h"
#import "VELCommonDefine.h"

@implementation VELFileConfig
- (NSTimeInterval)interval {
    return 1;
}

- (int)packetSize {
    return 0;
}

- (BOOL)isValid {
    return (VEL_IS_NOT_EMPTY_STRING(self.path) && [NSFileManager.defaultManager fileExistsAtPath:self.path]);
}
@end

@implementation VELVideoFileConfig
- (instancetype)init {
    if (self = [super init]) {
        _fps = 15;
        _width = 480;
        _height = 800;
        _fileType = VELVideoFileType_UnKnown;
    }
    return self;
}
- (NSTimeInterval)interval {
    return 1.0 / MAX(self.fps, 1);
}

- (int)packetSize {
    if (self.fileType == VELVideoFileType_BGRA) {
        return self.width * self.height * 4;
    }
    return self.width * self.height * 3 / 2;
}
- (NSString *)fileTypeDes {
    switch (self.fileType) {
        case VELVideoFileType_UnKnown : return @"UnKnown";
        case VELVideoFileType_BGRA : return @"bgra";
        case VELVideoFileType_NV12 : return @"nv12";
        case VELVideoFileType_NV21 : return @"nv21";
        case VELVideoFileType_YUV : return @"yuv420";
    }
    return @"UnKnown";
}
- (BOOL)isValid {
    return [super isValid] && self.fileType != VELVideoFileType_UnKnown;
}
@end

@implementation VELAudioFileConfig
- (instancetype)init {
    if (self = [super init]) {
        _readCountPerSecond = 100;
        _sampleRate = 44100;
        _bitDepth = 16;
        _channels = 2;
        _fileType = VELAudioFileType_UnKnown;
        _playable = YES;
    }
    return self;
}
- (NSTimeInterval)interval {
    return 1.0 / _readCountPerSecond;
}

- (int)packetSize {
    return self.sampleRate * (self.bitDepth / 8.0) * self.channels / _readCountPerSecond;
}

- (BOOL)isValid {
    return [super isValid] && self.fileType != VELAudioFileType_UnKnown;
}
@end

