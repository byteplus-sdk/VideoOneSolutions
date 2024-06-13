//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCFunctionSection.h"
#import "APIExample.h"

@implementation RTCFunctionSection

- (NSArray<__kindof BaseFunctionEntrance *> *)items {
    if (!_items) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        APIExample *example = [[APIExample alloc] init];
        if (example && example.isNeedShow) {
            [list addObject:example];
        }
        
        _items = [list copy];
    }
    return _items;
}

@end
