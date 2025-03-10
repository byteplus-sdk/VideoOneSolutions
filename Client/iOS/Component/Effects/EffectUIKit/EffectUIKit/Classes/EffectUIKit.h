// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifdef __OBJC__
#   import <UIKit/UIKit.h>
#else
#   ifndef FOUNDATION_EXPORT
#       if defined(__cplusplus)
#           define FOUNDATION_EXPORT extern "C"
#       else
#           define FOUNDATION_EXPORT extern
#       endif
#   endif
#endif

#if __has_include(<EffectUIKit/EffectUIKit.h>)

FOUNDATION_EXPORT double EffectUIKitVersionNumber;
FOUNDATION_EXPORT const unsigned char EffectUIKitVersionString[];

#import <EffectUIKit/EffectUIManager.h>
#import <EffectUIKit/EffectUIResourceHelper.h>

#else

#import "EffectUIManager.h"
#import "EffectUIResourceHelper.h"

#endif

