// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+MDElementDescripition.h"
#import "MDInterfaceElementDescription.h"
#import <objc/message.h>

@implementation UIView (MDElementDescripition)

- (void)setElementDescription:(id<MDInterfaceElementDescription>)elementDescription {
    objc_setAssociatedObject(self, @selector(elementDescription), elementDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<MDInterfaceElementDescription>)elementDescription {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)elementID {
    return [self.elementDescription elementID];
}

@end
