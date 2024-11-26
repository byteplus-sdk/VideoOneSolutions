//
//  RTCAudioEffectMixing.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCAudioEffectMixing.h"
#import "RTCJoinRTS.h"

@implementation RTCAudioEffectMixing

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"title_audio_effect_mixing", @"APIExample");
        self.iconName = @"function_icon_rtc_audio_effect_mix";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"AudioEffectMixingViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"title_audio_effect_mixing", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
