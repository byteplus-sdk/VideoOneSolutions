// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef IconItemCell_h
#define IconItemCell_h

#import <UIKit/UIKit.h>
#import "DownloadView.h"

@interface IconItemCell : UICollectionViewCell

@property (nonatomic, assign) BOOL useCellSelectedState;

@property (nonatomic, assign) BOOL isSelected;

- (void)updateWithIcon:(NSString *)iconName;

- (void)setDownloadState:(DownloadViewState)state;

- (void)setDownloadProgress:(CGFloat)progress;

@end

#endif /* IconItemCell_h */
