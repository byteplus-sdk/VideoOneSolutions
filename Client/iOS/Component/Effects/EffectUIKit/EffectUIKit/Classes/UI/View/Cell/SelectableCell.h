// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef SelectableCell_h
#define SelectableCell_h

#import "SelectableButton.h"

@interface SelectableCell : UICollectionViewCell

@property (nonatomic, assign) BOOL useCellSelectedState;

@property (nonatomic, strong) id<SelectableConfig> selectableConfig;

@property (nonatomic, readonly) SelectableButton *selectableButton;

- (void)updateProgress:(CGFloat)progress complete:(BOOL)complete;

@end

#endif /* SelectableCell_h */
