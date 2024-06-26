// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MediaLiveFunctionSection.h"
#import "VELCommon.h"
#import "MediaLiveCamera.h"
#import "MediaLiveScreen.h"
#import "MediaLiveVoice.h"
#import "MediaLiveFile.h"
#import "MediaLivePull.h"

@implementation MediaLiveFunctionSection

- (NSArray<__kindof BaseFunctionSection *> *)items {
    if (!_items) {
        BaseFunctionSection  *pushSection = [[BaseFunctionSection alloc] init];
        pushSection.tableSectionName = LocalizedStringFromBundle(@"medialive_push_section_title", @"MediaLive");
        
        pushSection.items = @[
           [MediaLiveCamera new],
           [MediaLiveVoice new],
           [MediaLiveScreen new],
           [MediaLiveFile new],
        ];
        [pushSection.items enumerateObjectsUsingBlock:^(__kindof BaseFunctionEntrance * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.marginTop = idx == 0 ? 8 : 0;
            obj.marginBottom = idx == 3 ? 8 : 0;
        }];
        
        BaseFunctionSection  *pullSection = [[BaseFunctionSection alloc] init];
        pullSection.tableSectionName = LocalizedStringFromBundle(@"medialive_pull_section_title", @"MediaLive");
        pullSection.items = @[ [MediaLivePull new]];
        _items = @[pushSection, pullSection];
    }
    return _items;
}

- (NSString *)functionSectionName {
    return LocalizedStringFromBundle(@"function_live_title", @"App");
}

@end
