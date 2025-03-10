// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

#import "EffectItem.h"

@protocol FaceBeautyViewDelegate <NSObject>

@required
- (void)onItemSelect:(EffectItem *)item;
- (void)onItemClean:(BOOL)isHidden;

@end

@interface FaceBeautyView : UIView

- (void)setItem:(EffectItem *)item;

- (void)resetSelect;

- (void)cleanSelect;

- (void)hiddenColorListAdapter:(BOOL)isHidden;

@property (nonatomic, weak) id<FaceBeautyViewDelegate> delegate;

@property (nonatomic, strong) NSString *titleType;

- (void)reloadData;

@end
