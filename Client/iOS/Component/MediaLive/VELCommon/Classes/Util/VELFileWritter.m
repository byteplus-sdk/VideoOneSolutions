// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFileWritter.h"
@interface VELFileWritter ()
@property (nonatomic, copy) NSString *rootDir;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, copy) NSString *defaultPath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end
@implementation VELFileWritter
- (instancetype)initWithFileConfig:(VELFileConfig *)fileConfig {
    if (self = [super init]) {
        self.fileConfig = fileConfig;
    }
    return self;
}

- (void)setFileConfig:(VELFileConfig *)fileConfig {
    @synchronized (self) {
        if (_fileConfig != nil) {
            [self close];
        }
        _fileConfig = fileConfig;
        if (_fileConfig != nil) {
            [self setupStream];            
        }
    }
}

- (void)setupStream {
    if (self.outputStream != nil) {
        [self.outputStream close];
        self.outputStream = nil;
    }
    NSString *path =  self.fileConfig.path;
    if (path == nil) {
        path = [self defaultPath];
        self.fileConfig.path = path;
    }
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
    }
    [NSFileManager.defaultManager createFileAtPath:path contents:nil attributes:nil];
    @synchronized (self) {
        self.outputStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:path] append:NO];
        [self.outputStream open];        
    }
}

- (void)writeData:(NSData *)data {
    @synchronized (self) {
        [self.outputStream write:data.bytes maxLength:data.length];
    }
}

- (void)writeBuffer:(const char *)buffer length:(int)length {
    @synchronized (self) {
        [self.outputStream write:(void *)buffer maxLength:length];
    }
}

- (void)close {
    @synchronized (self) {
        [self.outputStream close];
        self.outputStream = nil;
    }
}

- (NSString *)defaultPath {
    if (!_defaultPath) {
        _defaultPath = [self createDefaultPath];
    }
    return _defaultPath;
}

- (NSString *)createDefaultPath {
    if (self.fileConfig == nil ) {
        return nil;
    }
    if (self.fileConfig.path != nil && self.fileConfig.path.length > 0) {
        return self.fileConfig.path;
    }
    NSString *dirName = @"normal";
    NSString *timeStamp = [self.dateFormatter stringFromDate:NSDate.date];
    NSString *fileName = timeStamp;
    if ([self.fileConfig isKindOfClass:VELVideoFileConfig.class]) {
        VELVideoFileConfig *videoFile = (VELVideoFileConfig *)self.fileConfig;
        dirName = @"video";
        fileName = [NSString stringWithFormat:@"%@_%d_%d_%d_%@.yuv",timeStamp, videoFile.width, videoFile.height,videoFile.fps, videoFile.fileTypeDes];
    } else if ([self.fileConfig isKindOfClass:VELAudioFileConfig.class]) {
        dirName = @"audio";
        VELAudioFileConfig *audioFile = (VELAudioFileConfig *)self.fileConfig;
        fileName = [NSString stringWithFormat:@"%@_%d_%d_%d.pcm", timeStamp, audioFile.sampleRate, audioFile.channels, audioFile.bitDepth];
    }
    if (self.fileNamePrefix.length > 0) {
        fileName = [NSString stringWithFormat:@"%@_%@", self.fileNamePrefix, fileName];
    }
    NSString *dir = [self.rootDir stringByAppendingPathComponent:dirName];
    [self checkDir:dir];
    return [dir stringByAppendingPathComponent:fileName];
}

- (NSString *)rootDir {
    if (!_rootDir) {
        _rootDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        _rootDir = [_rootDir stringByAppendingPathComponent:@"file_write"];
        [self checkDir:_rootDir];
    }
    return _rootDir;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-dd-HH-mm-ss";
    }
    return _dateFormatter;
}

- (void)checkDir:(NSString *)dir {
    if (dir == nil) {
        return;
    }
    BOOL isDir = NO;
    if (![NSFileManager.defaultManager fileExistsAtPath:dir isDirectory:&isDir]
        || !isDir) {
        [NSFileManager.defaultManager createDirectoryAtPath:dir
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
}
@end
