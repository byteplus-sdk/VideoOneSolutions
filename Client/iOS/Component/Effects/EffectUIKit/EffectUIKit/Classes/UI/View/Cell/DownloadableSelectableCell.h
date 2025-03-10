// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef DownloadableSelectableCell_h
#define DownloadableSelectableCell_h

#import "SelectableButton.h"
#import "DownloadView.h"

@interface DownloadableSelectableCell : UICollectionViewCell

@property (nonatomic, assign) BOOL useCellSelectedState;

@property (nonatomic, strong) id<SelectableConfig> selectableConfig;

@property (nonatomic, readonly) SelectableButton *selectableButton;

@property (nonatomic, readonly) DownloadView *downloadView;

@end

#endif /* DownloadableSelectableCell_h */
