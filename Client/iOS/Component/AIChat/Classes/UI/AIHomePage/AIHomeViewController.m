//
//  AIHomdePageController.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AIHomeViewController.h"
#import "NetworkingManager+AIChat.h"
#import "AIRoomViewController.h"
#import "NetworkingManager+AIChat.h"
#import "AIRTCManager.h"
#import "AIConfigModel.h"
#import "AISettingManager.h"
#import "AIRoomInfoModel.h"
#import "AISettingViewController.h"

@interface AIHomeViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) BaseButton *settingBtn;

@property (nonatomic, strong) UIButton *callBtn;

@property (nonatomic, strong) UILabel *callBtnTextLabel;

@property (nonatomic, strong) AIRTCManager *rtcManager;

@end

@implementation AIHomeViewController
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self getAIConfig];
}

- (instancetype)initWithAppId:(NSString *)appId bid:(NSString *)bid {
    self = [super init];
    if (self) {
        _rtcManager = [AIRTCManager new];
        [_rtcManager connect:appId bid:bid block:^(BOOL result) {
            if (!result) {
                [[ToastComponent shareToastComponent] showWithMessage:@"Create rtcEngine failed!"];
            }
        }];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)getAIConfig {
    [[ToastComponent shareToastComponent] showLoading];
    [NetworkingManager requestAIConfig:^(AIConfigModel * _Nullable response) {
        [[ToastComponent shareToastComponent] dismiss];
        [[AISettingManager sharedInstance] initSettingModel:response];
    } fallure:^(NSString * _Nullable errMsg) {
        [[ToastComponent shareToastComponent] dismiss];
        [[ToastComponent shareToastComponent] showWithMessage:errMsg];
    }];
}

- (void)setupUI {
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.callBtn];
    [self.view addSubview:self.callBtnTextLabel];
    
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
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.right.equalTo(self.view).offset(-14);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(165);
    }];
    
    [self.callBtnTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-118);
    }];
    
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.callBtnTextLabel);
        make.bottom.equalTo(self.callBtnTextLabel.mas_top).offset(-20);
        make.size.mas_equalTo(CGSizeMake(66, 66));
    }];
}

#pragma mark - Action

- (void)backButtonClick {
    [self.rtcManager disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingBtnClick {
    AISettingViewController *settingVC = [[AISettingViewController alloc] initWithRTCManager:self.rtcManager];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)callBtnClick {
    AIRoomViewController *vc = [[AIRoomViewController alloc]  initWithRTCManager:self.rtcManager];
    [self.navigationController pushViewController:vc animated:YES];
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
        [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 36;
        paragraphStyle.maximumLineHeight = 36;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 10;
        
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:28 weight:UIFontWeightBold],
            NSForegroundColorAttributeName:[UIColor colorFromRGBHexString:@"#0D5EFF"],
            NSParagraphStyleAttributeName: paragraphStyle
        };
        
        NSAttributedString *attributedTitle = [[NSAttributedString alloc]
                                               initWithString:LocalizedStringFromBundle(@"ai_home_title", @"AIChat")
                                               attributes:attributes];
        _titleLabel.attributedText = attributedTitle;
    }
    return _titleLabel;
}

- (BaseButton *)settingBtn {
    if (!_settingBtn) {
        _settingBtn = [[BaseButton alloc] init];
        [_settingBtn setImage:[UIImage imageNamed:@"ai_settings" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

- (UIButton *)callBtn {
    if (!_callBtn) {
        _callBtn = [[UIButton alloc] init];
        [_callBtn setImage:[UIImage imageNamed:@"ai_call_icon" bundleName:@"AIChat"] forState:UIControlStateNormal];
        [_callBtn addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callBtn;
}

- (UILabel *)callBtnTextLabel {
    if (!_callBtnTextLabel) {
        _callBtnTextLabel = [[UILabel alloc] init];
        _callBtnTextLabel.text = LocalizedStringFromBundle(@"ai_home_call_btn", @"AIChat");
        _callBtnTextLabel.textColor = [UIColor blackColor];
        _callBtnTextLabel.textAlignment = NSTextAlignmentCenter;
        _callBtnTextLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightBold];
    }
    return _callBtnTextLabel;
}
@end
