// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupMenuBaseItem.h"

@implementation VELPopupMenuBaseItem
@synthesize title = _title;
@synthesize height = _height;
@synthesize width = _width;
@synthesize handler = _handler;
@synthesize menuView = _menuView;

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
    }
    return self;
}
- (void)updateAppearance {
    
}
- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, self.height);
}
@end
