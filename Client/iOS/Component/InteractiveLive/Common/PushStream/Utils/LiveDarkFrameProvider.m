//
//  LiveDarkFrameProvider.m
//  InteractiveLive
//
//  Created by bytedance on 2023/11/28.
//

#import "LiveDarkFrameProvider.h"
#import <TTSDK/LiveStreamMultiTimerManager.h>
#import <TTSDK/LCIHelper.h>
#import <CoreMedia/CMTime.h>

#define Live_NormalStream_DarkFrame_Identifier @"Live_NormalStream_DarkFrame_Identifier"

@interface LiveDarkFrameProvider () {
    CVPixelBufferRef _darkFrameImageBuffer;
}

@property (nonatomic, strong) LiveStreamMultiTimerManager *darkFrameTimer;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation LiveDarkFrameProvider

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    NSLog(@"aaa darframe dealloc");
    [self stopPushDarkFrame];
}


- (void)startPushDarkFrame {
    if (!_darkFrameTimer) {
        _darkFrameTimer = [[LiveStreamMultiTimerManager alloc] init];
    }
    if (!self.lock) {
        self.lock = [NSLock new];
    }
    WeakSelf;
    [_darkFrameTimer schedualTimerWithIdentifier:Live_NormalStream_DarkFrame_Identifier interval:1.0/15 queue:nil repeats:YES action:^{
        StrongSelf;
        if (!sself) {
            return;
        }
        [sself p_pushDarkFrameIfNeeded];
    }];
}

- (void)p_pushDarkFrameIfNeeded {    
    [self.lock lock];
    CVPixelBufferRef darkFrame = [self p_darkFrameForAudioStream];
    if (darkFrame == NULL) {
        [self.lock unlock];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(darkFrameProviderDidOutput:)]) {
        [self.delegate darkFrameProviderDidOutput:darkFrame];
    }
    [self.lock unlock];
}

- (CVPixelBufferRef)p_darkFrameForAudioStream {
    if (!_darkFrameImageBuffer) {
        _darkFrameImageBuffer = [[LCIHelper sharedInstance] createDarkFrameWithFrameSize:CGSizeMake(64, 64) enableLeakFix:YES];
    }
    return _darkFrameImageBuffer;
}

- (void)stopPushDarkFrame {
    [self.darkFrameTimer cancelTimerWithName:Live_NormalStream_DarkFrame_Identifier];
    self.darkFrameTimer = nil;
}

@end
