// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseCollectionLayout.h"

@implementation BaseCollectionLayout

- (CGFloat)minimumInteritemSpacing {
    return 0;
}

- (UIEdgeInsets)sectionInset{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect { 
    NSMutableArray* attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    return attributes;
}

@end
