// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSObject+VELAdd.h"
#import <objc/runtime.h>

@implementation NSObject (VELAdd)
- (NSString *)vel_className {
    return NSStringFromClass(self.class);
}

+ (NSString *)vel_className {
    return NSStringFromClass(self.class);
}

+ (Class)vel_metaclass {
    return objc_getMetaClass(NSStringFromClass(self.class).UTF8String);
}

+ (void)swizzleOriginal:(SEL)original replace:(SEL)other onInstance:(BOOL)instance {
    Class cls = instance ? self.class : self.vel_metaclass;
    Method originalMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, other);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, other, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
@end
