// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVTextInputComponent.h"
#import "KTVTextInputView.h"
#import "KTVRTSManager.h"

@interface KTVTextInputComponent ()

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) KTVTextInputView *textInputView;
@property (nonatomic, strong) KTVRoomModel *roomModel;
@property (nonatomic, copy) NSString *textMessage;
@property (nonatomic, assign) NSInteger maximumSendingLimit;
@property (nonatomic, assign) NSInteger currentSendingTimes;

@end

@implementation KTVTextInputComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maximumSendingLimit = 10;
        self.currentSendingTimes = 0;
        _superView = [DeviceInforTool topViewController].view;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyBoardDidShow:(NSNotification *)notifiction {
    if (!_textInputView) {
        return;
    }
    CGRect keyboardRect = [[notifiction.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _contentView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.textInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-keyboardRect.size.height);
        }];
    }];
    [_superView layoutIfNeeded];
}

- (void)keyBoardDidHide:(NSNotification *)notifiction {
    if (!_textInputView) {
        return;
    }
    _contentView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [self.textInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(48);
        }];
    }];
    [_superView layoutIfNeeded];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    __weak __typeof(self) wself = self;
    [_textInputView dismiss:^(NSString * _Nonnull text) {
        wself.textMessage = text;
    }];
}

#pragma mark - Publish Action

- (void)showWithRoomModel:(KTVRoomModel *)roomModel {
    _roomModel = roomModel;
    [self creatureTextInputView];
    [_superView layoutIfNeeded];
    [_textInputView show];
    __weak __typeof(self) wself = self;
    _textInputView.clickSenderBlock = ^(NSString * _Nonnull text) {
        wself.textMessage = @"";
        if (wself.currentSendingTimes >= wself.maximumSendingLimit) {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"send_message_exceeded_limit") delay:0.1];
            return;
        }
        [wself loadDataWithSendeMessage:text];
        if (wself.clickSenderBlock) {
            wself.clickSenderBlock(text);
        }
        wself.currentSendingTimes ++;
    };
}

#pragma mark - Private Action

- (void)creatureTextInputView {
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    [_superView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_superView);
    }];
    contentView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [contentView addGestureRecognizer:tap];
    contentView.hidden = YES;
    _contentView = contentView;
    
    KTVTextInputView *textInputView = [[KTVTextInputView alloc] initWithMessage:self.textMessage];
    [contentView addSubview:textInputView];
    [textInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(48);
        make.height.mas_equalTo(48);
    }];
    _textInputView = textInputView;
}

- (void)loadDataWithSendeMessage:(NSString *)message {
    [KTVRTSManager sendMessage:self.roomModel.roomID
                                    message:message
                         block:^(RTSACKModel * _Nonnull model) {
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
