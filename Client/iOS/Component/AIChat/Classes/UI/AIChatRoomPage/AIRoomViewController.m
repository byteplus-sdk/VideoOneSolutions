//
//  AIRoomViewController.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AIRoomViewController.h"
#import "NetworkingManager+AIChat.h"
#import "AISettingManager.h"
#import "AIQuestionLabel.h"
#import "AISettingViewController.h"
#import "AIAlertViewController.h"

typedef NS_ENUM(NSInteger, AIRoomStatus) {
    AIRoomStatusNone = 0,
    AIRoomStatusPreparing,
    AIRoomStatusReady,
    AIRoomStatusListening,
    AIRoomStatusSpeaking
};

static NSInteger AICHAT_TIME_LIMIT_MINUTES = 20;

@interface AIRoomViewController ()<AIRTCManagerDelegate, AIAlertViewControllerDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UILabel *countDownLabelView;

@property (nonatomic, strong) UIImageView *countDownIcon;

@property (nonatomic, strong) UIImageView *aiAvatarView;

@property (nonatomic, strong) UILabel *aiStatusLabel;

@property (nonatomic, strong) UIView *questionArea;

@property (nonatomic, strong) UILabel *listeningLabel;

@property (nonatomic, strong) UIImageView *listeningImageView;

@property (nonatomic, strong) UIButton *micBtn;

@property (nonatomic, strong) UIButton *leaveBtn;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) BaseButton *settingBtn;

@property (nonatomic, strong) AIRoomInfoModel *roomInfoModel;

@property (nonatomic, strong) AIRTCManager *rtcManager;

@property (nonatomic, assign) BOOL isMicOff;

@property (nonatomic, assign) AIRoomStatus roomStatus;

@property (nonatomic, assign) AIRoomStatus preRoomStatus;

@property (nonatomic, strong) GCDTimer *timer;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *lastKeepAiAgentQuestionsTime;

@property (nonatomic, strong) NSDate *lastLocalSpeechTime;

@property (nonatomic, assign) BOOL hasListeningState;

@end

@implementation AIRoomViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self joinRTCRoom];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.rtcManager startAudioCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.rtcManager stopAudioCapture];
}

- (instancetype)initWithRTCManager:(AIRTCManager *)rtcManager {
    self = [super init];
    if (self) {
        self.rtcManager = rtcManager;
        self.rtcManager.delegate = self;
    }
    return self;
}

#pragma mark - Private Method

- (void)joinRTCRoom {
    [self updateUI:AIRoomStatusPreparing];
    NSString *roomId = [[NSUUID UUID] UUIDString];
    [NetworkingManager requestRTCRoomToken:roomId success:^(NSString * _Nonnull token) {
        [self.rtcManager joinRoom:token roomId:roomId
                           userId:[LocalUserComponent userModel].uid
                            block:^(int res) {
            if (res == 0) {
                AIRoomInfoModel *roomInfo = [AIRoomInfoModel new];
                roomInfo.roomId = roomId;
                roomInfo.userId = [LocalUserComponent userModel].uid;
                self.roomInfoModel = roomInfo;
                [self startAIChat];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    } fallure:^(NSString * _Nullable errMsg) {
        [[ToastComponent shareToastComponent] showWithMessage:errMsg];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)startAIChat {
    if ([AISettingManager sharedInstance].settingModel.type == AIModelTypeRealTime) {
        [NetworkingManager requestStartRealTimeAIChat:self.roomInfoModel
                                          settingInfo:[AISettingManager sharedInstance].settingModel
                                              success:^(BOOL res) {} fallure:^(NSString * _Nullable errMsg) {
            [[ToastComponent shareToastComponent] showWithMessage:errMsg];
        }];
    } else {
        [NetworkingManager requestStartFlexibleAIChat:self.roomInfoModel
                                           settingInfo:[AISettingManager sharedInstance].settingModel
                                               success:^(BOOL res) {} fallure:^(NSString * _Nullable errMsg) {
            [[ToastComponent shareToastComponent] showWithMessage:errMsg];
        }];
    }
}

- (void)stopAIChat:(void (^)(BOOL res))block {
    [[ToastComponent shareToastComponent] showLoading];
    if ([AISettingManager sharedInstance].settingModel.type == AIModelTypeRealTime) {
        [NetworkingManager requestStopRealTimeAIChat:self.roomInfoModel
                                             success:^(BOOL res) {
            [[ToastComponent shareToastComponent] dismiss];
            if (block) {
                block(YES);
            }
        } fallure:^(NSString * _Nullable errMsg) {
            [[ToastComponent shareToastComponent] dismiss];
            [[ToastComponent shareToastComponent] showWithMessage:errMsg];
            if (block) {
                block(NO);
            }
        }];
    } else {
        [NetworkingManager requestStopFlexibleAIChat:self.roomInfoModel
                                              success:^(BOOL res) {
            [[ToastComponent shareToastComponent] dismiss];
            if (block) {
                block(YES);
            }
        } fallure:^(NSString * _Nullable errMsg) {
            [[ToastComponent shareToastComponent] dismiss];
            [[ToastComponent shareToastComponent] showWithMessage:errMsg];
            if (block) {
                block(NO);
            }
        }];
    }
}

- (void)setupUI {
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.countDownLabelView];
    [self.view addSubview:self.countDownIcon];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.aiAvatarView];
    [self.view addSubview:self.aiStatusLabel];
    [self.view addSubview:self.micBtn];
    [self.view addSubview:self.leaveBtn];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.left.mas_equalTo(16);
        make.size.equalTo(@(CGSizeMake(24, 24)));
    }];
    
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self.view).offset(-16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.countDownLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.backButton);
    }];

    [self.countDownIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(8, 8));
        make.centerY.equalTo(self.countDownLabelView);
        make.right.equalTo(self.countDownLabelView.mas_left).offset(-6);
    }];

    
    [self.aiAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(204, 197));
        make.top.equalTo(self.backButton.mas_bottom).offset(128);
        make.centerX.equalTo(self.view);
    }];
    
    [self.aiStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.aiAvatarView);
        make.top.equalTo(self.aiAvatarView.mas_bottom).offset(5);
    }];
    
    [self.micBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.left.equalTo(self.view).offset(42);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-26);
    }];
    
    [self.leaveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.right.equalTo(self.view).offset(-42);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-26);
    }];
    
    [self setupPresetQuestionArea];
}

- (void)setupPresetQuestionArea {
    [self.view addSubview:self.questionArea];
    [self.questionArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.aiAvatarView.mas_bottom).offset(50);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.micBtn.mas_top).offset(-20);
    }];

    UILabel *_questionTitleLabel = [[UILabel alloc] init];
    _questionTitleLabel.text = LocalizedStringFromBundle(@"ai_room_title", @"AIChat");
    _questionTitleLabel.textColor = [UIColor blackColor];
    _questionTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _questionTitleLabel.textAlignment = NSTextAlignmentCenter;
    _questionTitleLabel.numberOfLines = 0;
    [self.questionArea addSubview:_questionTitleLabel];
    [_questionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.questionArea);
    }];
    
    NSMutableArray *labelArr = [NSMutableArray array];
    [[AISettingManager sharedInstance].settingModel.presetQuestions
     enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                  NSUInteger idx,
                                  BOOL * _Nonnull stop) {
        AIQuestionLabel *_questionLabel = [[AIQuestionLabel alloc] init];
        _questionLabel.padding = UIEdgeInsetsMake(8, 10, 8, 8);
        _questionLabel.text = obj;
        _questionLabel.textColor = [UIColor colorFromRGBHexString:@"#42464E"];
        _questionLabel.backgroundColor = [UIColor whiteColor];
        _questionLabel.textAlignment = NSTextAlignmentCenter;
        _questionLabel.layer.cornerRadius = 8;
        _questionLabel.clipsToBounds = YES;
        _questionLabel.font = [UIFont systemFontOfSize:14];
        [self.questionArea addSubview:_questionLabel];
        [labelArr addObject:_questionLabel];
    }];
    
    [labelArr enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.questionArea).offset(21);
            if (idx == 0) {
                make.top.equalTo(_questionTitleLabel.mas_bottom).offset(18);
            } else {
                UILabel *prevLabel = labelArr[idx - 1];
                make.top.equalTo(prevLabel.mas_bottom).offset(6);
            }
        }];
    }];
}

- (void)updateUI:(AIRoomStatus)roomStatus {
    self.roomStatus = roomStatus;
    if (self.isMicOff) {
        return;
    }
    if (!self.questionArea.hidden && roomStatus != AIRoomStatusReady) {
        self.questionArea.hidden = YES;
        [self.aiAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom).offset(128);
        }];
    }
    switch (roomStatus) {
        case AIRoomStatusPreparing: {
            self.aiStatusLabel.text = LocalizedStringFromBundle(@"ai_room_preparing", @"AIChat");
            break;
        }
        case AIRoomStatusReady: {
            self.aiStatusLabel.text = @"";
            self.questionArea.hidden = NO;
            [self.aiAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.backButton.mas_bottom).offset(56);
            }];
            break;
        };
        case AIRoomStatusListening: {
            self.aiStatusLabel.text = LocalizedStringFromBundle(@"ai_room_listening", @"AIChat");
            break;
        }
        case AIRoomStatusSpeaking: {
            self.aiStatusLabel.text = LocalizedStringFromBundle(@"ai_room_speaking", @"AIChat");
            break;
        }
        default: {
            self.aiStatusLabel.text = @"";
            break;
        }
    }
}

- (void)setIsMicOff:(BOOL)isMicOff {
    _isMicOff = isMicOff;
    if (self.isMicOff) {
        self.aiStatusLabel.text = LocalizedStringFromBundle(@"ai_room_mute", @"AIChat");
        [self.aiAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backButton.mas_bottom).offset(56);
        }];
        self.questionArea.hidden = NO;
    } else {
        VOLogD(VOAIChat, @"setIsMicOff, %ld", self.roomStatus);
        [self updateUI:self.roomStatus];
    }
}

- (void)resetCountDown {
    _startDate = [NSDate date];
    self.countDownIcon.hidden = NO;
    self.timer = [[GCDTimer alloc] init];
    [self.timer start:1 block:^(BOOL result) {
        [self updateCountDownLabel];
    }];
}

- (void)updateCountDownLabel {
    NSDate *now = [NSDate date];
    NSInteger interval = [now timeIntervalSinceDate:self.startDate];
    NSInteger timeLeft = 60 * AICHAT_TIME_LIMIT_MINUTES - interval;
    if (timeLeft < 0) {
        [self onClickLeaveBtn];
    } else {
        NSInteger minute = timeLeft / 60;
        NSInteger second = timeLeft % 60;
        NSInteger hour = minute / 60;
        NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour,minute, second];
        self.countDownLabelView.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"ai_room_time_countdown", @"AIChat"), timeString];
    }
}
#pragma mark - AIRTCManagerDelegate

- (void)onActiveSpeakerChange:(BOOL)isLocalUser {
    NSDate *currentTime = [NSDate date];
    if (self.lastKeepAiAgentQuestionsTime) {
        NSTimeInterval timeIntervalInSeconds = [currentTime timeIntervalSinceDate:self.lastKeepAiAgentQuestionsTime];
        long long timeIntervalInMilliseconds = (long long)(timeIntervalInSeconds * 1000);
        if (timeIntervalInMilliseconds < 2000) {
            return;
        }
    }
    if (isLocalUser) {
        if (self.lastLocalSpeechTime) {
            NSTimeInterval timeIntervalInSeconds = [currentTime timeIntervalSinceDate:self.lastLocalSpeechTime];
            long long timeIntervalInMilliseconds = (long long)(timeIntervalInSeconds * 1000);
            if (timeIntervalInMilliseconds < 1000) {
                return;
            }
        }
        if (self.roomStatus != AIRoomStatusListening) {
            [self updateUI:AIRoomStatusListening];
        }
        self.hasListeningState = YES;
    } else {
        if (self.hasListeningState) {
            [self updateUI:AIRoomStatusSpeaking];
        }
    }
    self.lastLocalSpeechTime = currentTime;
}

- (void)onAIReady {
    [self resetCountDown];
    self.lastKeepAiAgentQuestionsTime = [NSDate date];
    self.lastLocalSpeechTime = nil;
    [self updateUI:AIRoomStatusReady];
}

#pragma mark - action

- (void)settingBtnClick {
    AIAlertViewController *alertVC = [[AIAlertViewController alloc] init];
    alertVC.delegate = self;
    [alertVC show];
}

- (void)onClickMicBtn {
    self.isMicOff = !self.isMicOff;
    if (self.isMicOff) {
        [self.rtcManager stopPublishAudio];
        [_micBtn setImage:[UIImage imageNamed:@"ai_mic_mute" bundleName:@"AIChat"] forState:UIControlStateNormal];
    } else {
        [self.rtcManager startPublishAudio];
        [_micBtn setImage:[UIImage imageNamed:@"ai_mic" bundleName:@"AIChat"] forState:UIControlStateNormal];
    }
}

- (void)onClickLeaveBtn {
    self.leaveBtn.userInteractionEnabled = NO;
    self.backButton.userInteractionEnabled = NO;
    [self stopAIChat:^(BOOL res) {
        [self.rtcManager leaveRoom];
        self.rtcManager.delegate = nil;
        self.rtcManager = nil;
        [self.timer stop];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - AIChatAlertViewControllerDelegate
- (void)onConfirmJumpToSettingVC {
    WeakSelf
    [self stopAIChat:^(BOOL res) {
        if (res) {
            self.countDownIcon.hidden = YES;
            self.countDownLabelView.text = @"";
            [self.rtcManager leaveRoom];
            [wself.timer stop];
            AISettingViewController *settingVC = [[AISettingViewController alloc] initWithRTCManager:self.rtcManager];
            settingVC.onBackBlock = ^{
                StrongSelf
                [sself joinRTCRoom];
            };
            [wself.navigationController pushViewController:settingVC animated:YES];
        }
    }];
}

#pragma mark - Getter
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"ai_background" bundleName:@"AIChat"];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImageView;
}

- (BaseButton *)backButton {
    if (!_backButton) {
        _backButton = [[BaseButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"ai_icon_back" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onClickLeaveBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (BaseButton *)settingBtn {
    if (!_settingBtn) {
        _settingBtn = [[BaseButton alloc] init];
        [_settingBtn setImage:[UIImage imageNamed:@"ai_settings" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (UILabel *)countDownLabelView {
    if (!_countDownLabelView) {
        _countDownLabelView = [[UILabel alloc] init];
        _countDownLabelView.textColor = [UIColor blackColor];
        _countDownLabelView.font = [UIFont systemFontOfSize:14];
    }
    return _countDownLabelView;
}

- (UIImageView *)countDownIcon {
    if (!_countDownIcon) {
        _countDownIcon = [[UIImageView alloc] init];
        _countDownIcon.image = [UIImage imageNamed:@"ai_red_dot" bundleName:@"AIChat"];
        _countDownIcon.backgroundColor = [UIColor redColor];
        _countDownIcon.hidden = YES;
    }
    return _countDownIcon;
}

- (UIImageView *)aiAvatarView {
    if (!_aiAvatarView) {
        _aiAvatarView = [[UIImageView alloc] init];
        _aiAvatarView.image = [UIImage imageNamed:@"ai_chat_ball" bundleName:@"AIChat"];
    }
    return _aiAvatarView;
}

- (UILabel *)aiStatusLabel {
    if (!_aiStatusLabel) {
        _aiStatusLabel = [[UILabel alloc] init];
        _aiStatusLabel.textColor = [UIColor blackColor];
        _aiStatusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _aiStatusLabel;
}

- (UIView *)questionArea {
    if (!_questionArea) {
        _questionArea = [[UIView alloc] init];
        _questionArea.backgroundColor = [UIColor clearColor];
        _questionArea.hidden = YES;
    }
    return _questionArea;
}

- (UIButton *)micBtn {
    if (!_micBtn) {
        _micBtn = [[UIButton alloc] init];
        _micBtn.backgroundColor = [UIColor whiteColor];
        _micBtn.layer.cornerRadius = 30;
        _micBtn.clipsToBounds = YES;
        [_micBtn setImage:[UIImage imageNamed:@"ai_mic" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_micBtn addTarget:self action:@selector(onClickMicBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micBtn;
}

- (UIButton *)leaveBtn {
    if (!_leaveBtn) {
        _leaveBtn = [[UIButton alloc] init];
        _leaveBtn.backgroundColor = [UIColor colorFromRGBHexString:@"#D7312A"];
        _leaveBtn.layer.cornerRadius = 30;
        _leaveBtn.clipsToBounds = YES;
        [_leaveBtn setImage:[UIImage imageNamed:@"ai_end_call" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_leaveBtn addTarget:self action:@selector(onClickLeaveBtn) forControlEvents:UIControlEventTouchUpInside];

    }
    return _leaveBtn;
}

@end
