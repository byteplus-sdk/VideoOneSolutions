// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BubbleTipView_h
#define BubbleTipView_h

#import <UIKit/UIkit.h>

@interface BubbleTipView : UIView

@property (nonatomic, assign) NSInteger tipIndex;

@property (nonatomic, strong) dispatch_block_t completeBlock;

@property (nonatomic, assign) BOOL blockInvoked;

@property (nonatomic, assign) BOOL needReshow;

- (void)update:(NSString *)title desc:(NSString *)desc;

@end

#endif /* BubbleTipView_h */
