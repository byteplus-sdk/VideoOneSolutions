// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef RectangleSelectableView_h
#define RectangleSelectableView_h

#import "BaseSelectableView.h"

@class RectangleSelectableView;
@interface RectangleSelectableConfig : NSObject <SelectableConfig>

+ (instancetype)initWithImageName:(NSString *)imageName imageSize:(CGSize)imageSize;

@property (nonatomic, copy) NSString *imageName;

- (RectangleSelectableView *)generateView;

@end

@interface RectangleSelectableView : BaseSelectableView

@property (nonatomic, strong) UIImageView *iv;

@end

#endif /* RectangleSelectableView_h */
