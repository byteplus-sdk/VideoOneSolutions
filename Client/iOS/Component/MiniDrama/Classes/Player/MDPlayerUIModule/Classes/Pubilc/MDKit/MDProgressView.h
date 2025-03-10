// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@interface MDProgressView : UIView

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, assign) NSTimeInterval currentValue;

@property (nonatomic, assign) NSTimeInterval bufferValue;

@property (nonatomic, assign) NSTimeInterval totalValue;

@end
