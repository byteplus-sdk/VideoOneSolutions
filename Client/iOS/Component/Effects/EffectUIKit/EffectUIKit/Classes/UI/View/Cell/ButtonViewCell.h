// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

@interface ButtonViewCell : UICollectionViewCell

- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg title:(NSString *)title expand:(BOOL)expand withPoint:(BOOL)withPoint;

- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg;

- (void)setPointOn:(BOOL)isOn;
@end
