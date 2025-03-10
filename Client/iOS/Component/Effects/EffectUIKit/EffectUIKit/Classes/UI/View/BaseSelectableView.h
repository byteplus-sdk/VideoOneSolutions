// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BaseSelectableView_h
#define BaseSelectableView_h

#import <UIKit/UIKit.h>

@class BaseSelectableView;
@protocol SelectableConfig <NSObject>

@property (nonatomic, assign) CGSize imageSize;

- (BaseSelectableView *)generateView;
@end

@interface BaseSelectableView : UIView

@property (nonatomic, assign) BOOL isSelected;

@end

#endif /* BaseSelectableView_h */
