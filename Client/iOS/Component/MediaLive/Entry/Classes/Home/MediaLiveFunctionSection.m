// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MediaLiveFunctionSection.h"
#import "MediaLiveAll.h"
#import <MediaLive/VELCommon.h>

@implementation MediaLiveFunctionSection

- (NSArray<__kindof BaseFunctionEntrance *> *)items {
    if (!_items) {
           NSMutableArray *list = [[NSMutableArray alloc] init];
            MediaLiveAll *mediaLive = [[MediaLiveAll alloc] init];
           if (mediaLive) {
               [list addObject:mediaLive];
           }
           _items = [list copy];
       }
       return _items;

}

- (NSString *)functionSectionName {
    return @"";
}

@end
