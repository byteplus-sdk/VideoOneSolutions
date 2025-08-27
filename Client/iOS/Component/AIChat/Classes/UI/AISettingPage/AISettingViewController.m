//
//  AISettingViewController.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AISettingViewController.h"
#import "AISettingManager.h"
#import "AISettingTableCellView.h"
#import "AITableSettingViewController.h"
#import "AITextSettingViewController.h"

static NSString *AISettingTableCellArrowViewIdentify = @"AISettingTableCellArrowViewIdentify";

@interface AISettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) BaseButton *backButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *tableHeaderView;

@property (nonatomic, strong) AISettingItemView *realTimeItem;

@property (nonatomic, strong) AISettingItemView *flexibleItem;

@property (nonatomic, strong) AIRTCManager *rtcManager;

@end

@implementation AISettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUIView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)initWithRTCManager:(AIRTCManager *)rtcManager {
    self = [super init];
    if (self) {
        self.rtcManager = rtcManager;
    }
    return self;
}

- (void)setupUIView {
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.backButton];
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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.top.equalTo(self.backButton.mas_bottom).offset(12);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(32);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-16);
    }];
}


- (void)backButtonClick {
    if (self.onBackBlock) {
        self.onBackBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)sectionList1 {
    AISettingTableCellModel *welcomeModel = [[AISettingTableCellModel alloc] init];
    welcomeModel.title = LocalizedStringFromBundle(@"ai_welcome_title", @"AIChat");
    welcomeModel.subTitle = [AISettingManager sharedInstance].settingModel.welcomeSpeech;
    welcomeModel.subTitlelayout = AISettingTableCellSubtitleLayoutVertical;
    welcomeModel.vcType = AITableSettingViewControllerTypeWelcome;
    
    AISettingTableCellModel *promptModel = [[AISettingTableCellModel alloc] init];
    promptModel.title = LocalizedStringFromBundle(@"ai_prompt_title", @"AIChat");
    promptModel.subTitle = [AISettingManager sharedInstance].settingModel.prompt;
    promptModel.subTitlelayout = AISettingTableCellSubtitleLayoutVertical;
    promptModel.vcType = AITableSettingViewControllerTypePrompt;
    
    return @[welcomeModel, promptModel];
}

- (NSArray *)sectionList2 {
    AISettingTableCellModel *voiceModel = [[AISettingTableCellModel alloc] init];
    voiceModel.title = LocalizedStringFromBundle(@"ai_voice_type", @"AIChat");
    voiceModel.subTitle = [AISettingManager sharedInstance].settingModel.currentVoiceRoleName;
    voiceModel.subTitlelayout = AISettingTableCellSubtitleLayoutHorizental;
    voiceModel.vcType = AITableSettingViewControllerTypeVoice;
    if ([AISettingManager sharedInstance].settingModel.type == AIModelTypeRealTime) {
        return @[voiceModel];
    } else {
        AISettingTableCellModel *llmModel = [[AISettingTableCellModel alloc] init];
        llmModel.title = LocalizedStringFromBundle(@"ai_llm_type", @"AIChat");
        llmModel.subTitle = [AISettingManager sharedInstance].settingModel.currentLLMVendorName;
        llmModel.subTitlelayout = AISettingTableCellSubtitleLayoutHorizental;
        llmModel.vcType = AITableSettingViewControllerTypeLLM;

        AISettingTableCellModel *asrModel = [[AISettingTableCellModel alloc] init];
        asrModel.title = LocalizedStringFromBundle(@"ai_asr_type", @"AIChat");
        asrModel.subTitle = [AISettingManager sharedInstance].settingModel.currentASRVendorName;
        asrModel.subTitlelayout = AISettingTableCellSubtitleLayoutHorizental;
        asrModel.vcType = AITableSettingViewControllerTypeASR;
        return @[voiceModel, llmModel, asrModel];
    }
}
// update AI IntegrationMode
- (void)onChooseRealTimeMode {
    if ( [AISettingManager sharedInstance].settingModel.type != AIModelTypeRealTime) {
        self.flexibleItem.isSelected = NO;
        self.realTimeItem.isSelected = YES;
        [AISettingManager sharedInstance].settingModel.type = AIModelTypeRealTime;
        [self.tableView reloadData];
    }
}

- (void)onChooseFlexible {
    if ( [AISettingManager sharedInstance].settingModel.type != AIModelTypeFlexible) {
        [AISettingManager sharedInstance].settingModel.type = AIModelTypeFlexible;
        self.realTimeItem.isSelected = NO;
        self.flexibleItem.isSelected = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self sectionList1].count;
    } else {
        return [self sectionList2].count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    UILabel *sectionTitle = [[UILabel alloc] init];
    if (section == 0) {
        sectionTitle.text =  LocalizedStringFromBundle(@"ai_character_setting", @"AIChat");
    } else {
        sectionTitle.text = LocalizedStringFromBundle(@"ai_core_function", @"AIChat");
    }
    sectionTitle.textColor = [UIColor colorFromRGBHexString:@"#737A87"];
    sectionTitle.font = [UIFont systemFontOfSize:14];
    
    [headerView addSubview:sectionTitle];
    [sectionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(16);
        make.left.equalTo(headerView).offset(16);
    }];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AISettingTableCellArrowView *cell = [tableView dequeueReusableCellWithIdentifier:AISettingTableCellArrowViewIdentify];
    if (!cell) {
        cell = [[AISettingTableCellArrowView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AISettingTableCellArrowViewIdentify];
    }
    NSArray *dataList = @[[self sectionList1], [self sectionList2]];
    cell.model = dataList[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSArray *dataList = @[[self sectionList1], [self sectionList2]];
    AISettingTableCellModel *model = dataList[indexPath.section][indexPath.row];
    if (section == 0) {
        AITextSettingViewController *vc = [[AITextSettingViewController alloc]
                                            initWithType:model.vcType];
        WeakSelf;
        vc.saveBlock = ^{
            StrongSelf;
            [sself.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AITableSettingViewController *vc = [[AITableSettingViewController alloc] initWithType:model.vcType rtcManager:self.rtcManager];
        WeakSelf;
        vc.saveBlock = ^{
            StrongSelf;
            [sself.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
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
        _titleLabel.text = LocalizedStringFromBundle(@"ai_setting_title", @"AIChat");
        _titleLabel.textColor = [UIColor colorFromRGBHexString:@"#1D2129"];
        _titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    }
    return _titleLabel;
}

- (AISettingItemView *)realTimeItem {
    if (!_realTimeItem) {
        _realTimeItem = [[AISettingItemView alloc] initWithType:AISettingTableCellViewTypeCheckMark];
        _realTimeItem.backgroundColor = [UIColor whiteColor];
        AISettingTableCellModel *model = [AISettingTableCellModel new];
        model.title = LocalizedStringFromBundle(@"ai_realtime_mode", @"AIChat");
        model.subTitle = @"";
        model.isSelected = [AISettingManager sharedInstance].settingModel.type == AIModelTypeRealTime;
        _realTimeItem.model = model;
        _realTimeItem.layer.cornerRadius = 8;
        _realTimeItem.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseRealTimeMode)];
        singleTap.numberOfTapsRequired = 1;
        [_realTimeItem addGestureRecognizer:singleTap];
    }
    return _realTimeItem;
}

- (AISettingItemView *)flexibleItem {
    if (!_flexibleItem) {
        _flexibleItem = [[AISettingItemView alloc] initWithType:AISettingTableCellViewTypeCheckMark];
        _flexibleItem.backgroundColor = [UIColor whiteColor];
        AISettingTableCellModel *model = [AISettingTableCellModel new];
        model.title = LocalizedStringFromBundle(@"ai_flexible_mode", @"AIChat");
        model.subTitle = @"";
        model.isSelected = [AISettingManager sharedInstance].settingModel.type == AIModelTypeFlexible;
        _flexibleItem.model = model;
        _flexibleItem.layer.cornerRadius = 8;
        _flexibleItem.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChooseFlexible)];
        singleTap.numberOfTapsRequired = 1;
        [_flexibleItem addGestureRecognizer:singleTap];
    }
    return _flexibleItem;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] init];
        _tableHeaderView.backgroundColor = [UIColor clearColor];
        _tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 32, 136);
        UILabel *headerTitle = [[UILabel alloc] init];
        headerTitle.text = LocalizedStringFromBundle(@"ai_integration_mode", @"AIChat");
        headerTitle.textColor = [UIColor colorFromRGBHexString:@"#737A87"];
        headerTitle.font = [UIFont systemFontOfSize:14];
        
        [_tableHeaderView addSubview:headerTitle];
        [_tableHeaderView addSubview:self.realTimeItem];
        [_tableHeaderView addSubview:self.flexibleItem];
        
        [headerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tableHeaderView);
            make.left.equalTo(_tableHeaderView).offset(16);
        }];
        
        [self.realTimeItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_tableHeaderView);
            make.top.equalTo(headerTitle.mas_bottom).offset(4);
            make.height.mas_equalTo(56);
        }];
        [self.flexibleItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.realTimeItem.mas_bottom);
            make.height.mas_equalTo(56);
            make.left.right.bottom.equalTo(_tableHeaderView);
        }];
    }
    return _tableHeaderView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:[AISettingTableCellArrowView class]
           forCellReuseIdentifier:AISettingTableCellArrowViewIdentify];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 58;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = 36;
        _tableView.sectionFooterHeight = 0;
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
    }
    return _tableView;
}

@end
