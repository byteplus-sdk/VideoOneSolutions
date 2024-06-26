// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <ToolKit/ToolKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SectionListView : UIView

- (instancetype)initWithList:(NSArray<BaseFunctionDataList *> *)sectionList;

@property (nonatomic, copy) void (^clickBlock)(NSInteger row);

- (void)updateItemWithCurIndex:(NSInteger)currentRow;

@end

NS_ASSUME_NONNULL_END
