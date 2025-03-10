// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef BaseBarView_h
#define BaseBarView_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BaserBarMode) {
    BaseBarBack = 1,
    BaseBarImagePicker = 2,
    BaseBarSetting = 4,
    BaseBarSwitch = 8,
    BaseBarAll = BaseBarBack | BaseBarImagePicker | BaseBarSetting | BaseBarSwitch,
};

@class BaseBarView;
@protocol BaseBarViewDelegate <NSObject>

- (void)baseView:(BaseBarView *)view didTapOpen:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapRecord:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapReset:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapBack:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapSetting:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapImagePicker:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapVideoPicker:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapSwitchCamera:(UIView *)sender;

- (void)baseView:(BaseBarView *)view didTapPlay:(UIView *)sender;

- (void)baseViewDidTouch:(BaseBarView *)view;

@end

@interface BaseBarView : UIView


@property (nonatomic, weak) id<BaseBarViewDelegate> delegate;

@property (nonatomic, strong) UIButton *btnPlay;

@property (nonatomic, strong) UIButton *btnBack;

@property (nonatomic, strong) UIButton *btnRecord;

@property (nonatomic, strong) UIButton *btnVideoPicker;

@property (nonatomic, assign) BOOL showReset;

@property (nonatomic, strong) UILabel *lInputResolution;


- (void)showBoard;

- (void)hideBoard;


- (void)showBar:(NSInteger)mode;

- (void)showProfile:(BOOL)show;

- (void)showPhotoNightSceneProfile:(BOOL) show;

- (void)updateProfile:(double)frameTime resolution:(CGSize)resolution;

- (void)updateProfile:(int)frameCount frameTime:(double)frameTime resolution:(CGSize)resolution;

@end

#endif /* BaseBarView_h */
