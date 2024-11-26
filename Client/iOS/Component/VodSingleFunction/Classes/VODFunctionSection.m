//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VODFunctionSection.h"
#import "PreventRecording.h"
#import "SmartSubtitles.h"
#import "VideoPlayback.h"
#import "PlayList.h"
#import <ToolKit/Localizator.h>

@implementation VODFunctionSection

- (NSArray<__kindof BaseFunctionSection *> *)items {
    if (!_items) {
        BaseFunctionSection *section = [[BaseFunctionSection alloc] init];
        section.tableSectionName = nil;
        section.items = @[[VideoPlayback new],
                          [PreventRecording new],
                          [SmartSubtitles new],
                          [PlayList new]];
        _items = @[section];
    }
    return _items;
}

- (NSString *)functionSectionName {
    return LocalizedStringFromBundle(@"function_vod_title", @"App");
}

@end
