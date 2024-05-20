// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFileReader.h"
#import "VELCommonDefine.h"

@interface VELFileReader ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (atomic, copy) VELFileDataBlock dataBlock;
@property (atomic, copy) FLEFileReadCompletionBlock completionBlock;
@property (nonatomic, strong) VELFileConfig *fileConfig;
@property (atomic, assign) BOOL isPaused;
@property (atomic, assign) BOOL isStoped;
@property (atomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) dispatch_queue_t timerQueue;
@end

@implementation VELFileReader
+ (instancetype)readerWithConfig:(__kindof VELFileConfig *)config {
    VELFileReader *reader = [[self alloc] init];
    reader.fileConfig = config;
    return reader;
}
- (void)startWithDataCallBack:(VELFileDataBlock)dataCallBack completion:(FLEFileReadCompletionBlock)completion {
    self.isStoped = NO;
    self.isPaused = NO;
    self.dataBlock = dataCallBack;
    self.completionBlock = completion;
    
    if (![self prepareFileRead]) {
        return;
    }
    
    if (!_timer) {
        NSString *queueName = [NSString stringWithFormat:@"com.velive.filereader.%@", self.fileConfig.path.lastPathComponent];
        self.timerQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_resume(_timer);
    }
    
    NSTimeInterval interval = self.fileConfig.interval;
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
    __weak __typeof__(self)weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        __strong __typeof__(weakSelf)self = weakSelf;
        [self readFileAndCallBack];
    });
}

- (void)stop {
    self.isStoped = YES;
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)pause {
    self.isPaused = YES;
}

- (void)resume {
    self.isPaused = NO;
}

- (BOOL)prepareFileRead {
    if (!self.fileConfig.isValid) {
        if (self.completionBlock) {
            self.completionBlock(VEL_ERROR(-1, @" file format error or file not found"), NO);
        }
        return NO;
    }
    if (self.inputStream == nil || !self.inputStream.hasBytesAvailable) {
        [self.inputStream close];
        self.inputStream = [NSInputStream inputStreamWithFileAtPath:self.fileConfig.path];
        [self.inputStream open];
    }
    return YES;
}

- (void)readFileAndCallBack {
    if (self.isPaused || self.isStoped || self.dataBlock == nil) {
        return;
    }
    if (!self.inputStream.hasBytesAvailable) {
        if (self.repeat) {
            [self prepareFileRead];
        } else {
            if (self.completionBlock) {
                vel_sync_main_queue(^{
                    self.completionBlock(nil, YES);
                });
            }
        }
        return;
    }
    
    int packetSize = self.fileConfig.packetSize;
    uint8_t *buffer = (uint8_t *)malloc(packetSize);
    NSInteger size = [self.inputStream read:buffer maxLength:packetSize];
    if (size == packetSize) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:size];
        if (self.dataBlock) {
            self.dataBlock(data, VEL_CURRENT_CMTIME);
        }
    } else {
        free(buffer);
    }
}

@end
