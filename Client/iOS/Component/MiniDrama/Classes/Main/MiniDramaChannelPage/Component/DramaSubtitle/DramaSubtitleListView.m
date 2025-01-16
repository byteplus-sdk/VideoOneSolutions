//
//  DramaSubtitleListView.m
//  MiniDrama
//
//  Created by ByteDance on 2024/12/6.
//

#import "DramaSubtitleListView.h"
#import <Masonry/Masonry.h>
#import "UIColor+String.h"
#import <ToolKit/ToolKit.h>

NSString * const DramaSubtitleListViewCellIdentify = @"DramaSubtitleListViewCellIdentify";

@interface DramaSubtitleListViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *highlightBackgroundView;

@end

@implementation DramaSubtitleListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style 
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.titleLabel];
    [self addSubview:self.highlightBackgroundView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.highlightBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-5);
        make.leading.equalTo(self).offset(12);
        make.trailing.equalTo(self).offset(-12);
    }];
}

- (void)setLanguage:(NSString *)language {
    _language = language;
    self.titleLabel.text = language;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.highlightedTextColor = [UIColor blueColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}
- (UIView *)highlightBackgroundView {
    if (!_highlightBackgroundView) {
        _highlightBackgroundView = [UIView new];
        _highlightBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.12];
        _highlightBackgroundView.layer.borderColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor];
        _highlightBackgroundView.layer.borderWidth = 1;
        _highlightBackgroundView.layer.cornerRadius = 1;
        _highlightBackgroundView.hidden = YES;
    }
    return _highlightBackgroundView;
}

@end



@interface DramaSubtitleListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *menuView;
@property (nonatomic, strong) UIVisualEffectView *backView;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation DramaSubtitleListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *contentView = [UIView new];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-30);
        make.width.equalTo(@(240));
        make.top.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(-20);
    }];
    
    [contentView addSubview:self.backView];
    [contentView addSubview:self.menuView];
    [contentView addSubview:self.titleLabel];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(20);
    }];
    
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(72);
        make.leading.trailing.bottom.equalTo(contentView);
    }];
}

- (void)setSubtitleList:(NSArray *)subtitleList {
    _subtitleList = subtitleList;
    [self.menuView reloadData];
}

- (void)show {
    UIView *parentView = [DeviceInforTool topViewController].view;
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
}

- (void)maskViewAction {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subtitleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DramaSubtitleListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DramaSubtitleListViewCellIdentify];
    cell.highlightBackgroundView.hidden = !(self.subtitleList[indexPath.row].subtitleId == self.currentSubtitleId);
    cell.language = self.subtitleList[indexPath.row].languageName;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChangeSubtitle:)]) {
        [self.delegate onChangeSubtitle:[self.subtitleList[indexPath.row] subtitleId]];
    }
    [self maskViewAction];
}
 
#pragma mark - Getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIVisualEffectView *)backView {
    if (!_backView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _backView = [[UIVisualEffectView alloc] initWithEffect:blur];
        }
    }
    return _backView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#B4B7BC"];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.text = LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
    }
    return _titleLabel;
}



- (UITableView *)menuView {
    if (!_menuView) {
        _menuView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_menuView registerClass:[DramaSubtitleListViewCell class] forCellReuseIdentifier:DramaSubtitleListViewCellIdentify];
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.delegate = self;
        _menuView.dataSource = self;
        _menuView.showsVerticalScrollIndicator = NO;
        _menuView.showsHorizontalScrollIndicator = NO;
        _menuView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _menuView;
}

@end
