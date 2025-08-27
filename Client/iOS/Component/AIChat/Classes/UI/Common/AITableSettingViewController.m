//
//  AIBaseSettingPage.m
//  AIChat
//
//  Created by ByteDance on 2025/3/19.
//

#import "AITableSettingViewController.h"

static NSString *AISettingTableCellButtonViewIdentify = @"AISettingTableCellButtonViewIdentify";

@interface AITableSettingViewController ()<UITableViewDelegate, UITableViewDataSource, AISettingTableCellViewDelegate, ByteRTCMediaPlayerEventHandler>

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) BaseButton *saveButton;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *vendorSelectView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<VoiceVenderType *> *dataSourceList;

@property (nonatomic, assign) NSInteger currentDataSourceIndex;

@property (nonatomic, copy) NSMutableArray<AIBaseInfo *> *dataSource;

@property (nonatomic, assign) AITableSettingViewControllerType type;

@property (nonatomic, copy) NSString *currentValue;

@property (nonatomic, copy) NSString *currentProviderName;

@property (nonatomic, copy) NSString *currentPreviewAudioName;

@property (nonatomic, strong) AIRTCManager *rtcManager;

@property (nonatomic, strong) ByteRTCMediaPlayer *rtcPlayer;

@property (nonatomic, assign) BOOL isPreviewing;

@end

@implementation AITableSettingViewController

- (instancetype)initWithType:(AITableSettingViewControllerType)type rtcManager:(AIRTCManager *)rtcManager{
    if (self = [super init]) {
        self.type = type;
        _currentPreviewAudioName = @"";
        _rtcManager = rtcManager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isPreviewing) {
        self.isPreviewing = NO;
        [self.rtcPlayer stop];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)setupView {
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.tableView];
    
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
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(self.backButton.mas_bottom).offset(12);
    }];
    
    if (self.dataSourceList && self.dataSourceList.count > 1) {
        [self.view addSubview:self.vendorSelectView];
        [self.vendorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(24);
            make.left.equalTo(self.view).offset(15);
            make.height.equalTo(@(40));
        }];
        __block BaseButton *preButton = nil;
        [self.dataSourceList enumerateObjectsUsingBlock:^(VoiceVenderType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BaseButton *btn = [[BaseButton alloc] init];
            [btn setTitle:obj.providerName forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorFromRGBHexString:@"#42464E"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorFromRGBHexString:@"#1664FF"] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            if (self.currentDataSourceIndex == idx) {
                [btn setBackgroundColor:[UIColor colorFromRGBHexString:@"#FFFFFF"]];
                btn.selected = YES;
            } else {
                [btn setBackgroundColor:[UIColor colorFromRGBHexString:@"#F1F3F5"]];
            }
            btn.layer.cornerRadius = 17;
            btn.layer.masksToBounds = YES;
            btn.tag = 3000 + idx;
            [btn addTarget:self action:@selector(onChangeDataSource:) forControlEvents:UIControlEventTouchUpInside];
            [self.vendorSelectView addSubview:btn];
            if (preButton) {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(preButton.mas_right).offset(3);
                    make.top.equalTo(self.vendorSelectView).offset(3);
                    make.bottom.equalTo(self.vendorSelectView).offset(-3);
                    make.width.greaterThanOrEqualTo(@100);
                    if (idx == self.dataSourceList.count - 1) {
                        make.right.equalTo(self.vendorSelectView).offset(-3);
                    }
                }];
            } else {
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.equalTo(self.vendorSelectView).offset(3);
                    make.bottom.equalTo(self.vendorSelectView).offset(-3);
                    make.width.greaterThanOrEqualTo(@100);
                }];
            }
            preButton = btn;
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.vendorSelectView.mas_bottom).offset(16);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-17);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-16);
        }];
    } else {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(30);
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-17);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-16);
        }];
    }
}

- (void)setType:(AITableSettingViewControllerType)type {
    _type = type;
    switch (type) {
        case AITableSettingViewControllerTypeVoice: {
            NSArray<VoiceVenderType *> *tempList;
            if ([AISettingManager sharedInstance].settingModel.type == AIModelTypeRealTime) {
                tempList = [AISettingManager sharedInstance].configModel.realtimeVoiceVendors;
            } else {
                tempList =  [AISettingManager sharedInstance].configModel.flexibleVoiceVendors;
            }
            self.dataSourceList = tempList;
            [self.dataSource addObjectsFromArray:tempList.firstObject.voiceList];
            self.currentDataSourceIndex = 0;
            self.currentValue = [AISettingManager sharedInstance].settingModel.currentVoiceRoleName;
            self.titleLabel.text = LocalizedStringFromBundle(@"ai_voice_type", @"AIChat");
            break;
        }
        case AITableSettingViewControllerTypeLLM: {
            [self.dataSource addObjectsFromArray: [AISettingManager sharedInstance].configModel.llmVendors];
            self.currentValue = [AISettingManager sharedInstance].settingModel.currentLLMVendorName;
            self.titleLabel.text = LocalizedStringFromBundle(@"ai_llm_type", @"AIChat");
            break;
        }
        case AITableSettingViewControllerTypeASR: {
            [self.dataSource addObjectsFromArray: [AISettingManager sharedInstance].configModel.asrVendors];
            self.currentValue = [AISettingManager sharedInstance].settingModel.currentASRVendorName;
            self.titleLabel.text = LocalizedStringFromBundle(@"ai_asr_type", @"AIChat");
            break;
        }
        default:
            break;
    }
}

- (BOOL)checkUpdate {
    switch (self.type) {
        case AITableSettingViewControllerTypeVoice: {
            return self.currentValue == [AISettingManager sharedInstance].settingModel.currentVoiceRoleName;
            break;
        }
        case AITableSettingViewControllerTypeLLM: {
            return self.currentValue == [AISettingManager sharedInstance].settingModel.currentLLMVendorName;
            break;
        }
        case AITableSettingViewControllerTypeASR: {
            return self.currentValue == [AISettingManager sharedInstance].settingModel.currentASRVendorName;
            break;
        }
        default:
            return NO;
            break;
    }
}

- (void)onChangeDataSource:(BaseButton *)sender {
    if (sender.tag - 3000 == self.currentDataSourceIndex) {
        return;
    }
    [self.vendorSelectView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BaseButton *btn = obj;
        if (btn.tag == sender.tag) {
            btn.selected = YES;
            btn.backgroundColor = [UIColor whiteColor];
        } else {
            btn.selected = NO;
            btn.backgroundColor = [UIColor colorFromRGBHexString:@"#F1F3F5"];
        }
    }];
    
    self.currentDataSourceIndex = sender.tag - 3000;
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:self.dataSourceList[self.currentDataSourceIndex].voiceList];
    [self.tableView reloadData];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSaveClick {
    switch (self.type) {
        case AITableSettingViewControllerTypeVoice: {
            [AISettingManager sharedInstance].settingModel.currentVoiceRoleName = self.currentValue;
            if (self.currentProviderName) {
                [AISettingManager sharedInstance].settingModel.currentVoiceProviderName = self.currentProviderName;
            }
            break;
        }
        case AITableSettingViewControllerTypeLLM: {
            [AISettingManager sharedInstance].settingModel.currentLLMVendorName = self.currentValue;
            break;
        }
        case AITableSettingViewControllerTypeASR: {
            [AISettingManager sharedInstance].settingModel.currentASRVendorName = self.currentValue;
            break;
        }
        default:
            break;
    }
    if (self.saveBlock) {
        self.saveBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ByteRTCMediaPlayerEventHandler
- (void)onMediaPlayerStateChanged:(int)playerId state:(ByteRTCPlayerState)state error:(ByteRTCPlayerError)error {
    VOLogD(VOAIChat, @"onMediaPlayerStateChanged, playerId: %d, state: %ld, error: %ld", playerId, state, error);
    WeakSelf
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (error != 0 ) {
            return;
        }
        if (state == ByteRTCPlayerStateFinished) {
            self.isPreviewing = NO;
            wself.currentPreviewAudioName = @"";
            [wself.tableView reloadData];
        } else if (state == ByteRTCPlayerStatePlaying) {
            self.isPreviewing = YES;
        }
    });
}

- (void)onMediaPlayerPlayingProgress:(int)playerId progress:(int64_t)progress {
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AISettingTableCellButtonView *cell = [tableView dequeueReusableCellWithIdentifier:AISettingTableCellButtonViewIdentify];
    AISettingTableCellModel *model = [[AISettingTableCellModel alloc] init];
    model.title = self.dataSource[indexPath.row].name;
    model.imageURL = self.dataSource[indexPath.row].icon;
    model.isSelected = [self.dataSource[indexPath.row].name isEqualToString:self.currentValue];
    model.isActive = self.currentPreviewAudioName == self.dataSource[indexPath.row].name;
    if (self.dataSource[indexPath.row].url && ![self.dataSource[indexPath.row].url isEqualToString:@""]) {
        model.link = self.dataSource[indexPath.row].url;
    }
    cell.model = model;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == AITableSettingViewControllerTypeVoice 
        && self.currentPreviewAudioName != self.dataSource[indexPath.row].name) {
        NSString *url = self.dataSource[indexPath.row].url;
        if (url && ![url isEqualToString:@""]) {
            ByteRTCMediaPlayerConfig *playConfig = [[ByteRTCMediaPlayerConfig alloc] init];
            playConfig.type = ByteRTCAudioMixingTypePlayout;
            playConfig.playCount = 1;
            playConfig.autoPlay = YES;
            [self.rtcPlayer open:url config:playConfig];
            self.currentPreviewAudioName = self.dataSource[indexPath.row].name;
            [self.tableView reloadData];
        } else {
            if (self.isPreviewing) {
                [self.rtcPlayer stop];
            }
            [[ToastComponent shareToastComponent]
             showWithMessage:LocalizedStringFromBundle(@"ai_audio_empty_error", @"AIChat")];
        }
    }
}

#pragma mark - AISettingTableCellViewDelegate
- (void)onClickButton:(NSString *)value {
    if (self.type == AITableSettingViewControllerTypeVoice) {
        self.currentProviderName = self.dataSourceList[self.currentDataSourceIndex].providerName;
    }
    if (![self.currentValue isEqual:value]) {
        self.currentValue = value;
        [self.tableView reloadData];
    }
}

    
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

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
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _saveButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = LocalizedStringFromBundle(@"ai_setting_title", @"AIChat");
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#1D2129"];
        _titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    }
    return _titleLabel;
}

- (UIView *)vendorSelectView {
    if (!_vendorSelectView) {
        _vendorSelectView = [[UIView alloc] init];
        _vendorSelectView.backgroundColor = [UIColor colorFromRGBHexString:@"#F1F3F5"];
        _vendorSelectView.layer.cornerRadius = 20;
        _vendorSelectView.layer.masksToBounds = YES;
    }
    return _vendorSelectView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[AISettingTableCellButtonView class]
           forCellReuseIdentifier:AISettingTableCellButtonViewIdentify];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.rowHeight = 75;
    }
    return _tableView;
}

- (ByteRTCMediaPlayer *)rtcPlayer {
    if (!_rtcPlayer) {
        _rtcPlayer = [self.rtcManager getMediaPlayer];
        [_rtcPlayer setEventHandler:self];
    }
    return _rtcPlayer;
}
@end
