// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UIDevice+idfvCheck.h"
#import <objc/runtime.h>
#import <ToolKit/ToolKit.h>

#ifdef DEBUG

@implementation UIDevice (idfvCheck)

+ (void)load {
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        SEL originalSelector = @selector(identifierForVendor);
        SEL swizzledSelector = @selector(hook_identifierForVendor);
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMehod = class_getInstanceMethod([self class], swizzledSelector);
        BOOL success = class_addMethod([self class], originalSelector, method_getImplementation(swizzledMehod), method_getTypeEncoding(swizzledMehod));
        if (success) {
            class_replaceMethod([self class], swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMehod);
        }
    });
}

- (NSUUID *)hook_identifierForVendor {
    VOLogI(VOToolKit,@"warning:use identifierForVendor.");
    return [self hook_identifierForVendor];
}

@end

#endif
