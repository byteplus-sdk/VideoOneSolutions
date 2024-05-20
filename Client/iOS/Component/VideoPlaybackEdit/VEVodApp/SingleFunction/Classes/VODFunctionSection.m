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

- (NSArray<__kindof BaseFunctionEntrance *> *)items {
    if (!_items) {
        _items = @[[VideoPlayback new],
                   [PlayList new],
                   [SmartSubtitles new],
                   [PreventRecording new]];
    }
    return _items;
}

- (NSString *)functionSectionName {
    return LocalizedStringFromBundle(@"function_vod_title", @"App");
}

@end
