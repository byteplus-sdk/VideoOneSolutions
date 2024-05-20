// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELCenterCollectionViewFlowLayout_h
#define VELCenterCollectionViewFlowLayout_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VELCollectionViewLayoutMode) {
    VELCollectionViewLayoutModeCenter,
    VELCollectionViewLayoutModeExpand,
    VELCollectionViewLayoutModeLeft,
};

@interface VELCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) VELCollectionViewLayoutMode mode;

@end

#endif /* VELCenterCollectionViewFlowLayout_h */
