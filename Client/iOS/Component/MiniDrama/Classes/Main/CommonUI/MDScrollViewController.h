// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

@protocol MDScrollViewDelegate <UITableViewDelegate>

- (void)scrollViewDidEndScrolling:(UIScrollView * _Nonnull)scrollView;

@end

@interface MDScrollViewController : UIViewController <UIScrollViewDelegate, MDScrollViewDelegate>

@property (nonatomic, readonly, strong, nonnull) UIScrollView *scrollView;

- (Class _Nullable)scrollViewClass;

@end
