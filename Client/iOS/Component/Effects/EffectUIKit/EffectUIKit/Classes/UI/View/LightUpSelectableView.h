// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef LightUpSelectableView_h
#define LightUpSelectableView_h

#import "BaseSelectableView.h"

@class LightUpSelectableView;
@interface LightUpSelectableConfig : NSObject <SelectableConfig>

+ (instancetype)initWithUnselectImage:(NSString *)unselectImage imageSize:(CGSize)imageSize;

//@property (nonatomic, copy) NSString *selectedImageName;
@property (nonatomic, copy) NSString *unselectedImageName;

- (LightUpSelectableView *)generateView;

@end

@interface LightUpSelectableView : BaseSelectableView

//@property (nonatomic, copy) NSString *selectedImageName;

@property (nonatomic, copy) NSString *unselectedImageName;

@end

#endif /* LightUpSelectableView_h */
