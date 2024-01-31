// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"
#import <objc/message.h>

@implementation UIView (VEElementDescripition)

- (void)setElementDescription:(id<VEInterfaceElementDescription>)elementDescription {
    objc_setAssociatedObject(self, @selector(elementDescription), elementDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<VEInterfaceElementDescription>)elementDescription {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)elementID {
    return [self.elementDescription elementID];
}

@end
