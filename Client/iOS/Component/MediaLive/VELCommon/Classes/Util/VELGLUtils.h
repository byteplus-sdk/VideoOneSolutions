// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELGLUtils_h
#define VELGLUtils_h

#import <OpenGLES/EAGL.h>

@interface VELGLUtils : NSObject

+ (EAGLContext *)createContextWithDefaultAPI:(EAGLRenderingAPI)api;

+ (EAGLContext *)createContextWithDefaultAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup *)sharegroup;

@end


#endif /* VELGLUtils_h */
