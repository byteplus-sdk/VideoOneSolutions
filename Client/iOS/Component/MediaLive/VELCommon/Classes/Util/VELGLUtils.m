// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELGLUtils.h"

@implementation VELGLUtils

+ (EAGLContext *)createContextWithDefaultAPI:(EAGLRenderingAPI)api {
    while (api != 0) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
        if (context != nil) {
            return context;
        }
        NSLog(@"not support api %lu, use lower api %lu", (unsigned long)api, [self vel_lowerAPI:api]);
        api = [self vel_lowerAPI:api];
    }
    return nil;
}

+ (EAGLContext *)createContextWithDefaultAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup *)sharegroup {
    while (api != 0) {
        EAGLContext *context = [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
        if (context != nil) {
            return context;
        }
        NSLog(@"not support api %lu, use lower api %lu", (unsigned long)api, [self vel_lowerAPI:api]);
        api = [self vel_lowerAPI:api];
    }
    return nil;
}

+ (EAGLRenderingAPI)vel_lowerAPI:(EAGLRenderingAPI)api {
    switch (api) {
        case kEAGLRenderingAPIOpenGLES3:
            return kEAGLRenderingAPIOpenGLES2;
        case kEAGLRenderingAPIOpenGLES2:
            return kEAGLRenderingAPIOpenGLES1;
        case kEAGLRenderingAPIOpenGLES1:
            return 0;
    }
    return 0;
}

@end
