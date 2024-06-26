// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullABRSettingViewController.h"
#import "VELSettingsCollectionView.h"
#import "VELSettingsSwitchViewModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
@interface VELPullABRSettingViewController () <UITextFieldDelegate>
@property(nonatomic, copy) void (^completionBlock)(VELPullABRSettingViewController *vc, VELPullABRUrlConfig *urlConfig);
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) VELSettingsCollectionView *settingCollectionView;
@property (nonatomic, strong) VELSettingsCollectionView *operationCollectionView;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) VELUIButton *qrButton;
@property (nonatomic, strong) UITextField *gopField;
@property (nonatomic, strong) UITextField *bitrateField;
@property (nonatomic, strong) VELUIButton *sendButton;
@property (nonatomic, strong) VELSettingsSwitchViewModel *defaultViewModel;
@property (nonatomic, strong) NSArray <VELSettingsSwitchViewModel *> *resolutionViewModels;
@property (nonatomic, strong) VELSettingsSwitchViewModel *originViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *uhdViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *hdViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *ldViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *sdViewModel;
@property (nonatomic, assign) BOOL isModify;
@end

@implementation VELPullABRSettingViewController
+ (instancetype)abrSettingWithSettingConfig:(VELPullSettingConfig *)settingConfig abrConfig:(VELPullABRUrlConfig *)abrConfig {
    VELPullABRSettingViewController *vc = [[self alloc] init];
    vc.settingConfig = settingConfig;
    vc.abrConfig = abrConfig;
    return vc;
}

- (void)showFromVC:(UIViewController *)vc completion:(nonnull void (^)(VELPullABRSettingViewController * _Nonnull, VELPullABRUrlConfig * _Nonnull))completion {
    vc = vc ?: UIApplication.sharedApplication.keyWindow.rootViewController;
    vc.definesPresentationContext = YES;
    self.completionBlock = completion;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    if (![vc.presentedViewController isKindOfClass:VELPullABRSettingViewController.class]) {
        [vc presentViewController:self animated:NO completion:nil];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    self.view.alpha = 0;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self setupConfig];
    [self setupContainer];
    [self setupCollectionSettings];
    [self.container setNeedsLayout];
    [self.container layoutIfNeeded];
}

- (void)setupConfig {
    if (self.abrConfig == nil) {
        self.abrConfig = [VELPullABRUrlConfig configWithUrl:nil
                                                       type:self.abrConfig.urlType];
        self.abrConfig.isDefault = NO;
        if ([self.settingConfig.urlConfig getDefaultABRConfig] == nil) {
            self.abrConfig.isDefault = YES;
        }
    } else {
        self.isModify = YES;
    }
    if (self.settingConfig.isNewApi) {
        self.abrConfig.gopSec = -1;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.container.isHidden) {
        self.container.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.container.alpha = 0;
        self.container.hidden = NO;
        self.view.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.container.transform = CGAffineTransformIdentity;
            self.container.alpha = 1;
            self.view.alpha = 1;
            [self.container setNeedsLayout];
            [self.container layoutIfNeeded];
        }];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
        self.container.alpha = 0;
        self.container.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        self.container.hidden = YES;
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)qrButtonClick {
    __weak __typeof__(self)weakSelf = self;
    [VELQRScanViewController showFromVC:self completion:^(VELQRScanViewController * _Nonnull vc, NSString * _Nonnull result) {
        __strong __typeof__(weakSelf)self = weakSelf;
        self.urlField.text = [result vel_trim];
        self.abrConfig.url = [result vel_trim];
        [vc hide];
    }];
}

- (void)sendButtonAction {
    [self.view endEditing:YES];
    
    if (VEL_IS_EMPTY_STRING(self.abrConfig.url.vel_validURLString)) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_pull_adress_error", @"MediaLive") detailText:@""];
        return;
    }
    
    if (![self.abrConfig.url hasPrefix:@"http"]) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_pull_support_http", @"MediaLive") detailText:@""];
        return;
    }
    
    if (self.abrConfig.format != VELPullUrlFormatFLV) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_pull_support_flv", @"MediaLive") detailText:@""];
        return;
    }
    
    if (self.completionBlock) {
        self.completionBlock(self, self.abrConfig);
    }
}

- (void)setupCollectionSettings {
    NSMutableArray <VELSettingsSwitchViewModel *>*resArray = [NSMutableArray arrayWithCapacity:5];
    [resArray addObject:self.originViewModel];
    [resArray addObject:self.uhdViewModel];
    [resArray addObject:self.hdViewModel];
    [resArray addObject:self.ldViewModel];
    [resArray addObject:self.sdViewModel];
    self.resolutionViewModels = resArray.copy;
    self.settingCollectionView.models =  resArray.copy;
    
    self.defaultViewModel.on = self.abrConfig.isDefault;
    self.operationCollectionView.models = @[self.defaultViewModel];
}

- (void)setupContainer {
    self.container = [[UIView alloc] init];
    self.container.layer.cornerRadius = 5;
    self.container.backgroundColor = VELViewBackgroundColor;
    self.container.hidden = YES;
    CGFloat containerHeight = 0;
    [self.navigationBar removeFromSuperview];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.titleLabel.text = LocalizedStringFromBundle(@"medialive_add_abr_gear_error", @"MediaLive");
    self.navigationBar.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.navigationBar.leftButton setImage:[VELUIImageMake(@"ic_close_white") vel_imageByTintColor:UIColor.blackColor] forState:(UIControlStateNormal)];
    __weak __typeof__(self)weakSelf = self;
    [self.navigationBar setLeftEventBlock:^{
        __strong __typeof__(weakSelf)self = weakSelf;
        [self hide];
    }];
    [self.container addSubview:self.navigationBar];
    [self.navigationBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(16);
        make.left.right.equalTo(self.container);
        make.height.mas_equalTo(24);
    }];
    containerHeight += 40;
    
    [self.container addSubview:self.settingCollectionView];
    [self.settingCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.container).mas_offset(-16);
        make.left.equalTo(self.container).mas_offset(16);
        make.top.equalTo(self.navigationBar.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(85);
    }];
    containerHeight += (85 + 20);
    
    self.urlField = [self createTextField:LocalizedStringFromBundle(@"medialive_pull_address_placeholder", @"MediaLive") keyboardType:(UIKeyboardTypeDefault)];
    self.urlField.text = self.abrConfig.url;
    [self.container addSubview:self.urlField];
    [self.urlField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.settingCollectionView);
        make.top.equalTo(self.settingCollectionView.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(35);
    }];
    
    [self.container addSubview:self.qrButton];
    [self.qrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.urlField.mas_right).mas_offset(8);
        make.right.equalTo(self.settingCollectionView.mas_right);
        make.centerY.equalTo(self.urlField);
    }];
    
    containerHeight += (35 + 8);
    
    
    self.bitrateField = [self createTextField:LocalizedStringFromBundle(@"medialive_bitrate_placeholder", @"MediaLive") keyboardType:(UIKeyboardTypeNumberPad)];
    if (self.abrConfig.bitrate > 0) {
        self.bitrateField.text = @(self.abrConfig.bitrate).stringValue;
    }
    [self.container addSubview:self.bitrateField];
    [self.bitrateField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.settingCollectionView);
        make.height.equalTo(self.urlField);
        if (!self.settingConfig.isNewApi) {
            make.top.equalTo(self.gopField.mas_bottom).mas_offset(8);
        } else {
            make.top.equalTo(self.urlField.mas_bottom).mas_offset(8);
        }
    }];
    containerHeight += (35 + 8);
    
    [self.container addSubview:self.operationCollectionView];
    [self.operationCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.settingCollectionView);
        make.top.equalTo(self.bitrateField.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(40);
    }];
    
    containerHeight += (40 + 8);
    
    [self.container addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.operationCollectionView.mas_bottom).mas_offset(40);
        make.left.right.equalTo(self.settingCollectionView);
        make.bottom.lessThanOrEqualTo(self.container).mas_offset(-25);
        make.height.mas_equalTo(34);
    }];
    containerHeight += (40 + 34 + 25);
    
    [self.view addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(14);
        make.right.equalTo(self.view).mas_offset(-14);
        make.centerY.equalTo(self.view);
        make.height.mas_equalTo(containerHeight);
    }];
}

- (void)keyBoardDidShow:(NSNotification *)notifiction {
    if (!self.container || !_sendButton) {
        return;
    }
    CGRect keyboardRect = [[notifiction.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect buttonRect = [self.container convertRect:self.sendButton.frame toView:self.view];
    CGFloat bottomHeight = self.view.frame.size.height -  (buttonRect.origin.y + buttonRect.size.height);
    CGFloat offsetY = 0;
    if (bottomHeight < keyboardRect.size.height) {
        offsetY = keyboardRect.size.height - bottomHeight;
    } else {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view).offset(-offsetY);
        }];
    }];
    [self.view layoutIfNeeded];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.urlField) {
        self.abrConfig.url = textField.text;
    } else if (textField == self.gopField) {
        self.abrConfig.gopSec = [textField.text integerValue];
    } else if (textField == self.bitrateField) {
        self.abrConfig.bitrate = [textField.text integerValue];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.tintColor = UIColor.clearColor;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        UITextPosition *position = [textField endOfDocument];
        [textField setSelectedTextRange:[textField textRangeFromPosition:position toPosition:position]];
        textField.tintColor = nil;
    }];
    [CATransaction commit];
}

- (UITextField *)createTextField:(NSString *)placeHolder keyboardType:(UIKeyboardType)keyboardType {
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 10)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textColor = [UIColor blackColor];
    textField.tintColor = UIColor.blackColor;
    textField.font = [UIFont systemFontOfSize:14];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.keyboardType = keyboardType;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:14],
        NSForegroundColorAttributeName : VELColorWithHexString(@"#C9CDD4")
    }];
    return textField;
}

- (VELUIButton *)qrButton {
    if (!_qrButton) {
        _qrButton = [[VELUIButton alloc] init];
        [_qrButton setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
        _qrButton.contentMode = UIViewContentModeLeft;
        _qrButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _qrButton.imagePosition = VELUIButtonImagePositionLeft;
        _qrButton.spacingBetweenImageAndTitle = 10;
        [_qrButton setImage:VELUIImageMake(@"vel_qr_scan") forState:(UIControlStateNormal)];
        [_qrButton addTarget:self action:@selector(qrButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _qrButton;
}

- (VELUIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[VELUIButton alloc] init];
        [_sendButton setTitle:self.isModify ? LocalizedStringFromBundle(@"medialive_confirm", @"MediaLive") : LocalizedStringFromBundle(@"medialive_add", @"MediaLive") forState:(UIControlStateNormal)];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        [_sendButton setBackgroundColor:VELColorWithHexString(@"#1A5DFE")];
        _sendButton.cornerRadius = 5;
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _sendButton;
}

- (VELSettingsCollectionView *)settingCollectionView {
    if (!_settingCollectionView) {
        _settingCollectionView = [[VELSettingsCollectionView alloc] init];
        _settingCollectionView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _settingCollectionView.layoutMode = VELCollectionViewLayoutModeLeft;
    }
    return _settingCollectionView;
}

- (VELSettingsCollectionView *)operationCollectionView {
    if (!_operationCollectionView) {
        _operationCollectionView = [[VELSettingsCollectionView alloc] init];
        _operationCollectionView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _operationCollectionView.layoutMode = VELCollectionViewLayoutModeLeft;
    }
    return _operationCollectionView;
}

- (VELSettingsSwitchViewModel *)defaultViewModel {
    if (!_defaultViewModel) {
        __weak __typeof__(self)weakSelf = self;
        NSString *title =LocalizedStringFromBundle(@"medialive_default", @"MediaLive");
        _defaultViewModel = [self createSwitchViewModelWith:title action:^(VELSettingsSwitchViewModel *model, BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.abrConfig.isDefault = isOn;
            if (isOn == NO && self.settingConfig.urlConfig.getDefaultABRConfig == nil) {
                [VELUIToast showText:LocalizedStringFromBundle(@"medialive_require_default", @"MediaLive") detailText:@""];
                self.abrConfig.isDefault = YES;
                model.on = YES;
                [model updateUI];
            }
            [self.settingConfig refreshABRConfig:self.abrConfig];
        }];
        
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
        NSStringDrawingUsesFontLeading;
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 55)
                                              options:opts
                                           attributes:attributes
                                              context:nil].size;
        
        _defaultViewModel.size = CGSizeMake(textSize.width + 60, 34);
    }
    return _defaultViewModel;
}

#define VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(title, p, res) \
- (VELSettingsSwitchViewModel *)p { \
    if (!_##p) { \
        _##p = [self createResolutionModel:title resolution:res]; \
    } \
    return _##p; \
}

VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"Origin", originViewModel, VELPullResolutionTypeOrigin);
VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"UHD", uhdViewModel, VELPullResolutionTypeUHD);
VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"HD", hdViewModel, VELPullResolutionTypeHD);
VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"LD", ldViewModel, VELPullResolutionTypeLD);
VEL_CREATE_DEFAULT_SWITCH_VIEW_MODE(@"SD", sdViewModel, VELPullResolutionTypeSD);

- (VELSettingsSwitchViewModel *)createResolutionModel:(NSString *)title resolution:(VELPullResolutionType)resolution {
    __weak __typeof__(self)weakSelf = self;
    VELSettingsSwitchViewModel *viewModel = [self createSwitchViewModelWith:title action:^(VELSettingsSwitchViewModel *model, BOOL isOn) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (![self.settingConfig.urlConfig.suggestedABRResolutions containsObject:model.extraInfo[@"RESOLUTION_TYPE"]]) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_xxx_has_configed", @"MediaLive"), model.title];
            model.on = NO;
            [model updateUI];
            return;
        }
        if (isOn) {
            [self.resolutionViewModels enumerateObjectsUsingBlock:^(VELSettingsSwitchViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj != model) {
                    obj.on = NO;
                    [obj updateUI];
                }
            }];
            self.abrConfig.resolution = resolution;
        }
    }];
    viewModel.extraInfo[@"RESOLUTION_TYPE"] = @(resolution);
    return viewModel;
}

- (VELSettingsSwitchViewModel *)createSwitchViewModelWith:(NSString *)title action:(void (^)(VELSettingsSwitchViewModel *model, BOOL isOn))action {
    VELSettingsSwitchViewModel *viewModel = [[VELSettingsSwitchViewModel alloc] init];
    viewModel.margin = UIEdgeInsetsZero;
    viewModel.insets = UIEdgeInsetsMake(8, 8, 8, 8);
    viewModel.hasBorder = YES;
    viewModel.hasShadow = YES;
    viewModel.title = title;
    viewModel.lightStyle = YES;
    viewModel.titleAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    viewModel.titleAttribute[NSForegroundColorAttributeName] = UIColor.blackColor;
    viewModel.size = CGSizeMake((VEL_DEVICE_WIDTH - 100) / 3, 34);
    [viewModel setSwitchModelBlock:action];
    return viewModel;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
