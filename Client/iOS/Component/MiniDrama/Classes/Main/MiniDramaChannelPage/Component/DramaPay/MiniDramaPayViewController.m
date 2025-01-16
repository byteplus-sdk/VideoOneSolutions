//
//  MiniDramaPayViewController.m
//  Pods
//
//  Created by zyw on 2024/7/23.
//

#import "MiniDramaPayViewController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/UIViewController+Orientation.h>
#import <SDWebImage/SDWebImage.h>
#import "MiniDramaPaymentView.h"
#import "BTDMacros.h"

#define PaymentTabHeight 372

#define PaymentTabWidth 375


@interface MiniDramaPayViewController ()<MiniDramaPaymentViewDelegate>
// Advertise Popup
@property (nonatomic, strong) UIView *popupView;
// Advertise page
@property (nonatomic, strong) UIImageView *advertiseImageView;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *closeAdButton;
@property (nonatomic, assign) BOOL isMute;
@property (nonatomic, assign) NSInteger leftSeconds;
@property (nonatomic, strong) GCDTimer *adTimer;
// pay page
@property (nonatomic, strong) MiniDramaPaymentView *payView;

@property (nonatomic, assign) BOOL isFirstShowPopup;

@property (nonatomic, assign) BOOL landscape;

@end

@implementation MiniDramaPayViewController

- (instancetype)initWithlandscape:(BOOL)landscape {
    self = [super init];
    if (self) {
        _landscape = landscape;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuratoinCustomView];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    self.popupView.hidden = YES;
    self.payView.hidden = YES;
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIView *maskView = [UIView new];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [maskView addGestureRecognizer:tap];
    [self configPopup];
    [self configAdverticePage];
    [self configPaymentPage];
}

- (void)configPopup {
     _popupView = [[UIView alloc] init];
    _popupView.hidden = YES;
    _popupView.backgroundColor = [UIColor colorFromHexString:@"#FFF9F1"];
    _popupView.layer.cornerRadius = 20;
    [self.view addSubview:_popupView];
    [_popupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(240, 223));
    }];
    
    UIImageView *unLockImageView = [[UIImageView alloc] init];
    unLockImageView.image = [UIImage imageNamed:@"mini_drama_ad_unlock" bundleName:@"MiniDrama"];
    [_popupView addSubview:unLockImageView];
    [unLockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_popupView);
        make.top.equalTo(_popupView).offset(-50);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor colorFromHexString:@"#51200C"];
    titleLabel.text = LocalizedStringFromBundle(@"mini_drama_watch_ad", @"MiniDrama");
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_popupView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_popupView).with.offset(20);
        make.centerX.equalTo(_popupView);
        make.width.lessThanOrEqualTo(_popupView).offset(-10);
    }];
    
    
    UILabel *episodeLabel = [[UILabel alloc] init];
    NSString *string1 = @"1";
    NSString *string2 = LocalizedStringFromBundle(@"mini_drama_episode", @"MiniDrama");
    NSString *stringAll = [NSString stringWithFormat:@"%@ %@", string1, string2];
    NSMutableAttributedString *atrributeString = [[NSMutableAttributedString alloc]
                                                  initWithString:stringAll];
    NSRange range1 = [stringAll rangeOfString:string1];
    NSRange range2 = [stringAll rangeOfString:string2];
    [atrributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:36 weight:UIFontWeightBold] range:range1];
    [atrributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] range:range2];
    [atrributeString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#FE2C55"] range:NSMakeRange(0, stringAll.length)];
    episodeLabel.attributedText = atrributeString;
    
    [_popupView addSubview:episodeLabel];
    [episodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).with.offset(8);
        make.centerX.equalTo(_popupView).with.offset(-10);
    }];
    
    
    UIButton *watchAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    watchAdButton.layer.cornerRadius = 18;
    [watchAdButton setBackgroundColor:[UIColor colorFromHexString:@"#FE2C55"]];
    [watchAdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    watchAdButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [watchAdButton setTitle:LocalizedStringFromBundle(@"mini_drama_watch_ad_button", @"MiniDrama") forState:UIControlStateNormal];
    [watchAdButton addTarget:self action:@selector(handleWatchAdvertise) forControlEvents:UIControlEventTouchUpInside];
    [_popupView addSubview:watchAdButton];
    [watchAdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(episodeLabel.mas_bottom).with.offset(16);
        make.leading.equalTo(_popupView).with.offset(24);
        make.trailing.equalTo(_popupView).with.offset(-24);
        make.height.mas_equalTo(36);
    }];
    
    UIButton *unLockAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unLockAllButton.layer.cornerRadius = 18;
    unLockAllButton.layer.borderWidth = 1;
    unLockAllButton.layer.borderColor = [[UIColor colorFromHexString:@"#FE2C55"] CGColor];
    [unLockAllButton setBackgroundColor:[UIColor whiteColor]];
    [unLockAllButton setTitleColor:[UIColor colorFromHexString:@"#FE2C55"] forState:UIControlStateNormal];
    unLockAllButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [unLockAllButton setTitle:LocalizedStringFromBundle(@"mini_drama_wactch_ad_all_button", @"MiniDrama") forState:UIControlStateNormal];
    [unLockAllButton addTarget:self action:@selector(handleUnlockAll) forControlEvents:UIControlEventTouchUpInside];
    [_popupView addSubview:unLockAllButton];
    [unLockAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(watchAdButton.mas_bottom).with.offset(10);
        make.leading.trailing.height.equalTo(watchAdButton);
    }];
}

- (void)configAdverticePage {
    [self.view addSubview:self.advertiseImageView];
    [self.advertiseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.advertiseImageView addSubview:self.muteButton];
    [self.advertiseImageView addSubview:self.closeAdButton];
    [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(67, 32));
        make.top.equalTo(self.advertiseImageView.mas_safeAreaLayoutGuideTop).offset(56);
        make.leading.equalTo(self.advertiseImageView).offset(16);
    }];
    [self.closeAdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(59, 32));
        make.top.equalTo(self.muteButton);
        make.trailing.equalTo(self.advertiseImageView).offset(-16);
    }];
}

- (void)configPaymentPage {
    [self.view addSubview:self.payView];
    if (self.landscape) {
        [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(18);
            make.bottom.equalTo(self.view).offset(-18);
            make.trailing.equalTo(self.view).offset(-44);
            make.width.mas_equalTo(375);
        }];
    } else {
        [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view);
            make.height.mas_equalTo(PaymentTabHeight);
            make.bottom.equalTo(self.view);
        }];
    }
}

- (void)showAdvertisePage {
    @weakify(self);
    NSURL *url = [NSURL URLWithString:@"https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/ad.gif"];
    [self.advertiseImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRefreshCached];
    if (self.landscape) {
        [self setDeviceInterfaceOrientation:UIInterfaceOrientationPortrait];
        self.advertiseImageView.hidden = NO;
    } else {
        self.advertiseImageView.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
        self.advertiseImageView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.advertiseImageView.transform  = CGAffineTransformMakeTranslation(0, 0);
        } completion:nil];
    }
    
    if (self.adTimer) {
        [self.adTimer resume];
    } else {
        self.adTimer = [[GCDTimer alloc] init];
    }
    self.leftSeconds = 10;
    [self.closeAdButton setTitle:[NSString stringWithFormat:@"%ld s", self.leftSeconds] forState:UIControlStateNormal];
    [self.closeAdButton setEnabled:NO];
    [self.closeAdButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 16)];
    [self.closeAdButton setImageEdgeInsets:UIEdgeInsetsMake(0, 26, 0, -26)];
    [self.adTimer start:1 block:^(BOOL result) {
        @strongify(self);
        self.leftSeconds = self.leftSeconds - 1;
    }];
}

- (void)showconfigPaymentPage {
    self.payView.count = MIN(3, self.count);
    self.payView.totalCount = self.vipCount;
    if (self.landscape) {
        self.payView.transform = CGAffineTransformMakeTranslation(PaymentTabWidth + 44, 0);
    } else {
        self.payView.transform = CGAffineTransformMakeTranslation(0, PaymentTabHeight);
    }
    self.payView.hidden = NO;
    @weakify(self);
    [UIView animateWithDuration:0.5 animations:^{
        @strongify(self);
        self.payView.transform  = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
}

#pragma mark - Public
- (void)showPopup {
    if (self.popupView.hidden || !self.view.superview) {
        self.isFirstShowPopup = YES;
        UIViewController *topViewController = [DeviceInforTool topViewController];
        if (topViewController) {
            [topViewController addChildViewController:self];
            [topViewController.view addSubview:self.view];
            [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(topViewController.view);
            }];
        }
        self.popupView.hidden = NO;
        self.advertiseImageView.hidden = YES;
        self.payView.hidden = YES;
    }
}

- (void)showPayview {
    self.isFirstShowPopup = NO;
    UIViewController *topViewController = [DeviceInforTool topViewController];
    if (topViewController) {
        [topViewController addChildViewController:self];
        [topViewController.view addSubview:self.view];
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(topViewController.view);
        }];
    }
    self.popupView.hidden = YES;
    self.advertiseImageView.hidden = YES;
    [self showconfigPaymentPage];
}

- (void)setDramaInfo:(MDDramaInfoModel *)dramaInfo {
    _dramaInfo = dramaInfo;
    self.payView.dramaInfo = dramaInfo;
}

#pragma mark - Private

- (void)handleUnlockAll {
    self.popupView.hidden = YES;
    [self showconfigPaymentPage];
}

- (void)handleWatchAdvertise {
    self.popupView.hidden = YES;
    [self showAdvertisePage];
}

- (void)setLeftSeconds:(NSInteger)leftSeconds {
    _leftSeconds = leftSeconds;
    if (leftSeconds <= 0) {
        [self.adTimer suspend];
        [self.closeAdButton setTitle:@"" forState:UIControlStateNormal];
        [self.closeAdButton setEnabled:YES];
        [self.closeAdButton setImageEdgeInsets:UIEdgeInsetsZero];
    } else {
        [self.closeAdButton setTitle:[NSString stringWithFormat:@"%ld s", leftSeconds] forState:UIControlStateNormal];
    }
}
- (void)handleMuteChange {
    
}
- (void)handleCloseAdvertiseView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUnlockEpisode:count:)]) {
        [self.delegate onUnlockEpisode:self count:1];
    }
}

#pragma mark - MiniDramaPaymentViewDelegate
- (void)onClosePaymentView {
    if (self.isFirstShowPopup) {
        @weakify(self);
        if (self.landscape) {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                self.payView.transform  = CGAffineTransformMakeTranslation(PaymentTabWidth + 44, 0);
            } completion:^(BOOL finished) {
                @strongify(self);
                self.payView.hidden = YES;
                self.popupView.hidden = NO;
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                @strongify(self);
                self.payView.transform  = CGAffineTransformMakeTranslation(0, PaymentTabHeight);
            } completion:^(BOOL finished) {
                @strongify(self);
                self.payView.hidden = YES;
                self.popupView.hidden = NO;
            }];
        }
    } else {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }
}
- (void)onPayEpisodesWithCount:(NSInteger)count {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUnlockEpisode:count:)]) {
        [self.delegate onUnlockEpisode:self count:count];
    }
}
- (void)onPayAllEpisodes {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onUnlockAllEpisodes:)]) {
        [self.delegate onUnlockAllEpisodes:self];
    }
}

#pragma mark - Getter
- (MiniDramaPaymentView *)payView {
    if (!_payView) {
        _payView = [[MiniDramaPaymentView alloc] initWitLanscape:self.landscape];
        _payView.backgroundColor = [UIColor colorFromHexString:@"#FFF9F1"];
        _payView.hidden = YES;
        _payView.delegate = self;
        if (self.landscape) {
            _payView.layer.cornerRadius = 8;
        } else {
            _payView.layer.cornerRadius = 20;
            _payView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        }
    }
    return _payView;
}

- (UIImageView *)advertiseImageView {
    if (!_advertiseImageView) {
        _advertiseImageView = [[UIImageView alloc] init];
        _advertiseImageView.hidden = YES;
        _advertiseImageView.userInteractionEnabled = YES;
    }
    return _advertiseImageView;
}

- (UIButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteButton.layer.cornerRadius = 8;
        [_muteButton setBackgroundColor:[UIColor colorFromHexString:@"#0000008A"]];
        _muteButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [_muteButton addTarget:self action:@selector(handleMuteChange) forControlEvents:UIControlEventTouchUpInside];
        [_muteButton setTitle:@"Ad  |" forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"mini_drama_mute" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        [_muteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 18)];
        [_muteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 28, 0, -28)];
    }
    return _muteButton;
}

- (UIButton *)closeAdButton {
    if (!_closeAdButton) {
        _closeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeAdButton setBackgroundColor:[UIColor colorFromHexString:@"#0000008A"]];
        _closeAdButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _closeAdButton.layer.cornerRadius = 8;
        [_closeAdButton setEnabled:NO];
        [_closeAdButton addTarget:self action:@selector(handleCloseAdvertiseView) forControlEvents:UIControlEventTouchUpInside];
        [_closeAdButton setImage:[UIImage imageNamed:@"mini_drama_ad_close" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
    }
    return _closeAdButton;
}

- (void)dealloc
{
    if (self.adTimer) {
        [self.adTimer stop];
        self.adTimer = nil;
    }
}

@end
