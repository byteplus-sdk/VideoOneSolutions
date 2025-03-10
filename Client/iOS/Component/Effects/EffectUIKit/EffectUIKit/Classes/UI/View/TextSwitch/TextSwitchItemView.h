// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef TextSwitchItemView_h
#define TextSwitchItemView_h

#import <UIKit/UIKit.h>

@interface TextSwitchItem : NSObject

+ (instancetype)initWithTitle:(NSString *)title pointColor:(UIColor *)pointColor highlightTextColor:(UIColor *)highlightTextColor normalTextColor:(UIColor *)normalTextColor;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, strong) UIColor *highlightTextColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, assign) CGFloat minTextWidth;

@end

@class TextSwitchItemView;
@protocol TextSwitchItemViewDelegate <NSObject>

- (void)textSwitchItemView:(TextSwitchItemView *)view didSelect:(TextSwitchItem *)item;

@end

@interface TextSwitchItemView : UIView

@property (nonatomic, weak) id<TextSwitchItemViewDelegate> delegate;
@property (nonatomic, strong) TextSwitchItem *item;
@property (nonatomic, assign) BOOL selected;

@end

#endif /* TextSwithItemView_h */
