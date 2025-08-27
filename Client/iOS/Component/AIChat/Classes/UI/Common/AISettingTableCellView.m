//
//  AIUITabItemView.m
//  AIChat
//
//  Created by ByteDance on 2025/3/17.
//

#import "AISettingTableCellView.h"
#import <SDWebImage/SDWebImage.h>
//AISettingTableCellModel
@implementation AISettingTableCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"";
        _subTitle = @"";
        _subTitlelayout = AISettingTableCellSubtitleLayoutHorizental;
        _image = nil;
        _imageURL = @"";
        _link = @"";
        _vcType = AITableSettingViewControllerTypeNone;
    }
    return self;
}

@end

//AISettingTableCellArrowView
@implementation AISettingTableCellArrowView

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.itemView];
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(2);
        make.bottom.equalTo(self.contentView).offset(-2);
        make.height.greaterThanOrEqualTo(@(58));
    }];
}

- (void)setModel:(AISettingTableCellModel *)model {
    _model = model;
    self.itemView.model = model;
}

- (AISettingItemView *)itemView {
    if (!_itemView) {
        _itemView = [[AISettingItemView alloc] initWithType:AISettingTableCellViewTypeArrow];
        _itemView.backgroundColor = [UIColor whiteColor];
        _itemView.layer.cornerRadius = 8;
        _itemView.clipsToBounds = YES;
    }
    return _itemView;
}

@end

//AISettingTableCellButtonView
@implementation AISettingTableCellButtonView

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}


- (void)setupView {
    [self.contentView addSubview:self.itemView];
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-3);
    }];
}

- (void)setModel:(AISettingTableCellModel *)model {
    _model = model;
    self.itemView.model = model;
}

#pragma mark - AISettingTableCellViewDelegate
- (void)onClickButton:(NSString *)value {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickButton:)]) {
        [self.delegate onClickButton:value];
    }
}

- (AISettingItemView *)itemView {
    if (!_itemView) {
        _itemView = [[AISettingItemView alloc] initWithType:AISettingTableCellViewTypeButton];
        _itemView.backgroundColor = [UIColor whiteColor];
        _itemView.layer.cornerRadius = 8;
        _itemView.clipsToBounds = YES;
        _itemView.delegate = self;
    }
    return _itemView;
}
@end

//AISettingItemView
@interface AISettingItemView()
@property (nonatomic, assign) AISettingTableCellViewType styleType;
@property (nonatomic, strong) UIImageView *prefixView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *suffixView;
@property (nonatomic, strong) UIView *maskView;
@end

@implementation AISettingItemView

- (instancetype)initWithType:(AISettingTableCellViewType)styleType {
    self = [super init];
    if (self) {
         _styleType = styleType;
        [self setupView];
    }
    return self;
}

- (void)setupView {
    switch (self.styleType) {
        case AISettingTableCellViewTypeArrow:
            [self setupArrowView];
            break;
        case AISettingTableCellViewTypeButton:
            [self setupButtonView];
            break;
        case AISettingTableCellViewTypeCheckMark:
            [self setupCheckMarkView];
            break;
        default:
            [self setupArrowView];
            break;
    }
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make)  {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self.suffixView);
    }];
}

- (void)setupArrowView {
    UIImageView *arrowIcon = [[UIImageView alloc]
                              initWithImage:[UIImage
                                             imageNamed:@"ai_arrow_right"
                                             bundleName:@"AIChat"]];
    self.suffixView = arrowIcon;
    [self addSubview:self.suffixView];
    [self.suffixView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-12);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
}

- (void)setupButtonView {
    UIButton *buttonView = [[UIButton alloc] init];
    buttonView.layer.cornerRadius = 16;
    buttonView.clipsToBounds = YES;
    [buttonView setTitleColor:[UIColor colorFromRGBHexString:@"#42464E"] forState:UIControlStateNormal];
    [buttonView setTitleColor:[UIColor colorFromRGBHexString:@"#FFFFFF"] forState:UIControlStateSelected];
    buttonView.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [buttonView setImage:[UIImage imageNamed:@"ai_check_white" bundleName:@"AIChat"] forState:UIControlStateSelected];
    [buttonView addTarget:self action:@selector(onClickSelect) forControlEvents:UIControlEventTouchUpInside];
    [buttonView setTitle:LocalizedStringFromBundle(@"ai_setting_button_not_choose", @"AIChat")
                                                   forState:UIControlStateNormal];
    [buttonView setTitle:LocalizedStringFromBundle(@"ai_setting_button_chosen", @"AIChat")
                forState:UIControlStateSelected];
    [buttonView setTitleEdgeInsets:UIEdgeInsetsMake(6, 8, 6, 8)];
    self.suffixView = buttonView;
    [self addSubview:self.suffixView];
    [self.suffixView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-12);
        make.size.mas_greaterThanOrEqualTo(CGSizeMake(72, 32));
    }];
}

- (void)setupCheckMarkView {
    UIImageView *checkMarkIcon = [[UIImageView alloc]
                              initWithImage:[UIImage
                                             imageNamed:@"ai_check"
                                             bundleName:@"AIChat"]];
    self.suffixView = checkMarkIcon;
    [self addSubview:self.suffixView];
    [self.suffixView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.equalTo(self).offset(-16);

    }];
}
- (void)updateButton {
    UIButton *button = (UIButton *)self.suffixView;
    button.selected = self.model.isSelected;
    if (self.model.isSelected) {
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_greaterThanOrEqualTo(CGSizeMake(88, 32));
        }];
        button.backgroundColor = [UIColor colorFromRGBHexString:@"#1664FF"];
    } else {
        button.backgroundColor = [UIColor colorFromRGBHexString:@"#E8F1FF"];
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_greaterThanOrEqualTo(CGSizeMake(72, 32));
        }];
    }
}
- (void)updateSubTitle {
    [self addSubview:self.subTitleLabel];
    self.subTitleLabel.text = self.model.subTitle;
    
    if (self.model.subTitlelayout == AISettingTableCellSubtitleLayoutHorizental) {
        self.subTitleLabel.textAlignment = NSTextAlignmentRight;
        self.subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(16);
            make.centerY.equalTo(self.suffixView);
        }];
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.suffixView);
            make.left.lessThanOrEqualTo(self.titleLabel.mas_right).offset(6);
            make.right.equalTo(self.suffixView.mas_left).offset(-6);
        }];
    } else {
        self.subTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.subTitleLabel.numberOfLines = 0;
        self.subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(15);
            make.left.equalTo(self).offset(16);
            make.right.equalTo(self.suffixView.mas_left).offset(-12);
        }];
        
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make)  {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.suffixView.mas_left).offset(-12);
            make.height.lessThanOrEqualTo(@(80));
            make.bottom.equalTo(self).offset(-15);
        }];
    }
}
- (void)updatePrefixView {
    NSURL *imageURL = [NSURL URLWithString:self.model.imageURL];
    [self.prefixView sd_setImageWithURL:imageURL
                       placeholderImage:self.model.image];
    [self addSubview:self.prefixView];
    [self.prefixView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(8);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.prefixView.mas_right).offset(22);
        if (self.suffixView) {
            make.right.mas_lessThanOrEqualTo(self.suffixView.mas_left).offset(10);
        }
        make.centerY.equalTo(self.suffixView);
    }];
    
    if (self.model.isActive) {
        [self.prefixView addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.prefixView);
        }];
    } else {
        [self.maskView removeFromSuperview];
    }
}

#pragma mark -Setter
- (void)setModel:(AISettingTableCellModel *)model {
    _model = model;
    self.titleLabel.text = model.title;

    if (model.image || ![model.imageURL isEqualToString:@""]) {
        [self updatePrefixView];
    }
        
    if (model.subTitle && ![model.subTitle isEqualToString:@""]) {
        [self updateSubTitle];
    }
    self.isSelected = model.isSelected;
}

- (BOOL)isSelected {
    return self.model.isSelected;
}

- (void)setIsSelected:(BOOL)isSelected {
    self.model.isSelected = isSelected;
    if (self.styleType == AISettingTableCellViewTypeButton) {
        [self updateButton];
    } else if (self.styleType == AISettingTableCellViewTypeCheckMark) {
       self.suffixView.hidden = !self.model.isSelected;
   }
}
- (void)onClickSelect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickButton:)]) {
        [self.delegate onClickButton:self.model.title];
    }
}

#pragma mark - Getter

- (UIImageView *)prefixView {
    if (!_prefixView) {
        _prefixView = [[UIImageView alloc] init];
    }
    return _prefixView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = [UIColor colorFromRGBHexString:@"#80838A"];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLabel;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.5 * 255];
        _maskView.layer.cornerRadius = 8;
        _maskView.clipsToBounds = YES;
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ai_audio_playing" bundleName:@"AIChat"]];
        [_maskView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.center.equalTo(_maskView);
        }];
    }
    return _maskView;
}
@end
