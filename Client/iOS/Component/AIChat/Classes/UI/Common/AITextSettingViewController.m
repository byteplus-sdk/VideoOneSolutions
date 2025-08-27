//
//  AITextSettingViewController.m
//  AIChat
//
//  Created by ByteDance on 2025/3/19.
//

#import "AITextSettingViewController.h"

@interface AITextSettingViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) BaseButton *saveButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) NSString *currentValue;

@property (nonatomic, assign) AITableSettingViewControllerType type;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSDictionary *atrributeDictionary;

@property (nonatomic, strong) UILabel *limitLabel;

@property (nonatomic, assign) NSInteger limitCount;

@end

@implementation AITextSettingViewController

- (instancetype)initWithType:(AITableSettingViewControllerType)type{
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.limitLabel];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.left.mas_equalTo(16);
        make.size.equalTo(@(CGSizeMake(24, 24)));
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self.view).offset(-16);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self.view);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(26);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        if (self.type == AITableSettingViewControllerTypeWelcome) {
            make.height.equalTo(@(118));
        } else {
            make.height.equalTo(@(300));
        }
    }];
    [self.limitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.textView.mas_right).offset(-16);
        make.bottom.equalTo(self.textView.mas_bottom).offset(-11);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)setType:(AITableSettingViewControllerType)type {
    _type = type;
    if (type == AITableSettingViewControllerTypeWelcome) {
        self.limitCount = 100;
        self.titleLabel.text = LocalizedStringFromBundle(@"ai_welcome_title", @"AIChat");
        self.currentValue = [AISettingManager sharedInstance].settingModel.welcomeSpeech;
    } else if (type == AITableSettingViewControllerTypePrompt) {
        self.limitCount = 512;
        self.titleLabel.text = LocalizedStringFromBundle(@"ai_prompt_title", @"AIChat");
        self.currentValue = [AISettingManager sharedInstance].settingModel.prompt;
    }
}

- (void)hideKeyboard {
    [self.textView resignFirstResponder];
}

- (void)backButtonClick {
    [self hideKeyboard];
//    NSString *oldValue;
//    if (self.type == AITableSettingViewControllerTypeWelcome) {
//        oldValue = [AISettingManager sharedInstance].settingModel.welcomeSpeech;
//    } else {
//        oldValue = [AISettingManager sharedInstance].settingModel.prompt;
//    }
//    if (![oldValue isEqualToString:self.currentValue]) {
//        [self hideKeyboard];
//
//        return;
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSaveClick {
    [self hideKeyboard];
    if (self.type == AITableSettingViewControllerTypeWelcome) {
        [AISettingManager sharedInstance].settingModel.welcomeSpeech = self.currentValue;
    } else {
        [AISettingManager sharedInstance].settingModel.prompt = self.currentValue;
    }
    if (self.saveBlock) {
        self.saveBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setCurrentValue:(NSString *)currentValue {
    _currentValue = currentValue;
    self.textView.text = currentValue;
    self.limitLabel.text = [NSString stringWithFormat:@"%ld/%ld", currentValue.length, self.limitCount];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > self.limitCount) {
        textView.text = [textView.text substringToIndex:self.limitCount];
    }
    self.currentValue = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.textView resignFirstResponder];
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

- (BaseButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[BaseButton alloc] init];
        [_saveButton setTitle:LocalizedStringFromBundle(@"ai_setting_save", @"AIChat") forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor colorFromRGBHexString:@"#1664FF"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(onSaveClick) forControlEvents:UIControlEventTouchUpInside];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    }
    return _saveButton;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#161823"];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius = 8;
        _textView.layer.masksToBounds = YES;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        _textView.textContainerInset =  UIEdgeInsetsMake(11, 16, 0, 16);
        _textView.typingAttributes = self.atrributeDictionary;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textView.delegate = self;
    }
    return _textView;
}

- (NSDictionary *)atrributeDictionary {
    if (!_atrributeDictionary) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        UIFont *font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _atrributeDictionary = @{
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: [UIColor colorFromRGBHexString:@"#161823"],
        };
    }
    return _atrributeDictionary;
}
- (UILabel *)limitLabel {
    if (!_limitLabel) {
        _limitLabel = [[UILabel alloc] init];
        _limitLabel.textColor = [UIColor colorFromRGBHexString:@"#737A87"];
        _limitLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
        _limitLabel.textAlignment = NSTextAlignmentRight;
    }
    return _limitLabel;
}
@end
