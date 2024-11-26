// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveTextInputComponent.h"
#import "LiveMessageModel.h"
#import <ToolKit/TextInputView.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/LocalUserComponent.h>
#import <Masonry/Masonry.h>

@interface LiveTextInputComponent ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) TextInputView *textInputView;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *textMessage;
@property (nonatomic, assign) NSInteger maximumSendingLimit;
@property (nonatomic, assign) NSInteger currentSendingTimes;

@end

@implementation LiveTextInputComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maximumSendingLimit = 10;
        self.currentSendingTimes = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)keyBoardDidShow:(NSNotification *)notifiction {
    if (!_textInputView) {
        return;
    }
    CGRect keyboardRect = [[notifiction.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        [self.textInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-keyboardRect.size.height);
        }];
    }];
    [self.textInputView.superview layoutIfNeeded];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    __weak __typeof(self) wself = self;
    [self.textInputView dismiss:^(NSString *_Nonnull text) {
        [wself close];
    }];
}

#pragma mark - Publish Action

- (void)showWithRoomID:(NSString *) roomID {
    self.roomID = roomID;
    [self creatureTextInputView];
    [self.textInputView show];
    __weak __typeof(self) wself = self;
    self.textInputView.clickSenderBlock = ^(NSString *_Nonnull text) {
        wself.textMessage = @"";
        [wself.textInputView dismiss:^(NSString *_Nonnull text) {
            [wself close];
        }];
        if (wself.currentSendingTimes >= wself.maximumSendingLimit) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"send_message_exceeded_limit", @"LiveRoomUI") delay:0.1];
            return;
        }
        if (wself.clickSenderBlock) {
            wself.clickSenderBlock(text);
        }
        wself.currentSendingTimes++;
    };
}

- (void)close {
    if (self.textInputView.superview) {
        [self.textInputView removeFromSuperview];
        self.textInputView = nil;
    }
    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
}

- (void)disappear {
    if (self.textInputView && self.textInputView.superview) {
        __weak __typeof(self) wself = self;
        [self.textInputView dismiss:^(NSString *_Nonnull text) {
            [wself close];
        }];
    }
}

#pragma mark - Private Action

- (void)creatureTextInputView {
    UIView *topView = [DeviceInforTool topViewController].view;
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [topView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(topView);
    }];

    contentView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [contentView addGestureRecognizer:tap];
    _contentView = contentView;

    TextInputView *textInputView = [[TextInputView alloc] initWithMessage:self.textMessage];
    [contentView addSubview:textInputView];
    [textInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(52);
        make.height.mas_equalTo(52);
    }];
    [textInputView.superview layoutIfNeeded];
    _textInputView = textInputView;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
