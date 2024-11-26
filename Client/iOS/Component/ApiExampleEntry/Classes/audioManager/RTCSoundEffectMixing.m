//
//  RTCSoundEffectMixing.m
//  App
//
//  Created by ByteDance on 2024/6/3.
//

#import "RTCSoundEffectMixing.h"
#import "RTCJoinRTS.h"


@implementation RTCSoundEffectMixing

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = LocalizedStringFromBundle(@"example_voice_effect", @"APIExample");
        self.iconName = @"function_icon_rtc_sound_effect";
        self.bundleName = @"ApiExampleEntry";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    UIViewController *vc = [[NSClassFromString(@"SoundEffectsViewController") alloc] init];
    [vc setValue:LocalizedStringFromBundle(@"example_voice_effect", @"APIExample") forKey:@"titleText"];
    [RTCJoinRTS joinRTS:vc block:block];
}

@end
