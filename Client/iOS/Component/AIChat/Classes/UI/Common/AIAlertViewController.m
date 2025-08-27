//
//  AIAlertViewController.m
//  AIChat
//
//  Created by ByteDance on 2025/3/20.
//

#import "AIAlertViewController.h"
#import "AISettingViewController.h"

@interface AIAlertViewController ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *settingButton;

@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation AIAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.settingButton];
    [self.contentView addSubview:self.cancelButton];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(240, 44));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.settingButton.mas_bottom).offset(20);
        make.left.right.equalTo(self.settingButton);
        make.bottom.equalTo(self.contentView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(240, 44));
    }];
        
    
}

- (void)show {
    UIViewController *topVC = [DeviceInforTool topViewController];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [topVC presentViewController:self animated:NO completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)settingButtonClicked:(UIButton *)sender {
    self.settingButton.userInteractionEnabled = NO;
    [self dismiss];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConfirmJumpToSettingVC)]) {
        [self.delegate onConfirmJumpToSettingVC];
    }
}

- (void)cancelButtonClicked:(UIButton *)sender {
    [self dismiss];
}

#pragma mark - Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClicked:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedStringFromBundle(@"ai_alert_title", @"AIChat");
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#4E5969"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        [_settingButton setTitle:LocalizedStringFromBundle(@"ai_alert_setting", @"AIChat") forState:UIControlStateNormal];
        [_settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _settingButton.layer.cornerRadius = 6;
        _settingButton.clipsToBounds = YES;
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorFromRGBHexString:@"#3B91FF"].CGColor,
                                 (__bridge id)[UIColor colorFromRGBHexString:@"#0D5EFF "].CGColor,
                                 (__bridge id)[UIColor colorFromRGBHexString:@"#C069FF"].CGColor,
        ];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.frame = CGRectMake(0, 0, 240, 44);
        gradientLayer.cornerRadius = _settingButton.layer.cornerRadius;
        [_settingButton.layer insertSublayer:gradientLayer atIndex:0];
    }
    return _settingButton;
    
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:LocalizedStringFromBundle(@"ai_alert_cancel", @"AIChat") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.layer.cornerRadius = 6;
        _cancelButton.clipsToBounds = YES;
        _cancelButton.layer.borderWidth = 1;
        _cancelButton.layer.borderColor = [UIColor colorFromRGBHexString:@"#EAEAEA"].CGColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _cancelButton;
}

@end
