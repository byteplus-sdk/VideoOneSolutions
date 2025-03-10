// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef EffectCollectionFlowLayout_h
#define EffectCollectionFlowLayout_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EffectUIKitCollectionLayoutMode) {
    EffectUIKitCollectionLayoutModeCenter,
    EffectUIKitCollectionLayoutModeExpand,
    EffectUIKitCollectionLayoutModeLeft,
};

@interface EffectCollectionFlowLayout : UICollectionViewFlowLayout

// default EffectUIKitCollectionLayoutModeCenter
@property (nonatomic, assign) EffectUIKitCollectionLayoutMode mode;

@end

#endif /* EffectCollectionFlowLayout_h */
