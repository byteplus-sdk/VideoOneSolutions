// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDDramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaPaymentViewDelegate <NSObject>

- (void)onClosePaymentView;

- (void)onPayEpisodesWithCount:(NSInteger)count;

- (void)onPayAllEpisodes;

@end

@interface MiniDramaPaymentView : UIView

- (instancetype)initWitLanscape:(BOOL)landscape;

@property (nonatomic, strong) MDDramaInfoModel *dramaInfo;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, weak) id<MiniDramaPaymentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
