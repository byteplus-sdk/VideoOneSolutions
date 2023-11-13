// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LoginComponent.h"

#if __has_include("MenuLoginHome.h")
#import "MenuLoginHome.h"
#endif

@implementation LoginComponent

+ (BOOL)showLoginVCIfNeed:(BOOL)isAnimation {
    Class<LoginProtocol> impClass = self.impClass;
    if (impClass) {
        return [impClass showLoginVCIfNeed:isAnimation];
    }
    return NO;
}

+ (void)showLoginVCAnimated:(BOOL)isAnimation {
    Class<LoginProtocol> impClass = self.impClass;
    if (impClass) {
        [impClass showLoginVCAnimated:isAnimation];
    }
}

+ (void)closeAccount:(void (^ _Nullable)(BOOL))block {
    Class<LoginProtocol> impClass = self.impClass;
    if (impClass) {
        [impClass closeAccount:block];
    }
}

+ (Class<LoginProtocol>)impClass {
    Class impClass = nil;
#if __has_include("MenuLoginHome.h")
    impClass = [MenuLoginHome class];
#endif
    if (impClass && [impClass conformsToProtocol:@protocol(LoginProtocol)]) {
        return impClass;
    }
    return nil;
}

@end
