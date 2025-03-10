// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef MDPlayerInteractionDefine_h
#define MDPlayerInteractionDefine_h

typedef NS_OPTIONS(NSUInteger, MDGestureType) {
    MDGestureType_None           = 0,
    MDGestureType_SingleTap      = 1 << 0,
    MDGestureType_DoubleTap      = 1 << 1,
    MDGestureType_Pan            = 1 << 2,
    MDGestureType_LongPress      = 1 << 3,
    MDGestureType_Pinch          = 1 << 4,
    MDGestureType_All            = NSUIntegerMax,
};

#endif /* MDPlayerInteractionDefine_h */
