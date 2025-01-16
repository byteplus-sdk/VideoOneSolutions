//
//  MiniDramaPaymentView.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/26.
//

#import "MiniDramaPaymentView.h"
#import <ToolKit/ToolKit.h>
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>


@interface MiniDramaPaymentView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *dramaTitle;
@property (nonatomic, strong) UILabel *episodeCountLabel;
@property (nonatomic, strong) UILabel *tipLabel1;
@property (nonatomic, strong) UILabel *tipLabel2;
@property (nonatomic, strong) UIImageView *tipImage1;
@property (nonatomic, strong) UIImageView *tipImage2;
@property (nonatomic, strong) UIView *payOptionView1;
@property (nonatomic, strong) UIView *payOptionView2;
@property (nonatomic, strong) UIButton *payButton;
@property (nonatomic, assign) CGFloat price;

@property (nonatomic, assign) BOOL isUnlockAll;
@property (nonatomic, assign) BOOL landscape;
@end

@implementation MiniDramaPaymentView

- (instancetype)initWitLanscape:(BOOL)landscape {
    self = [super init];
    if (self) {
        _landscape = landscape;
        [self configCustomUI];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTabtriggered:)];
        tap.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:tap];
        self.isUnlockAll = false;
    }
    return self;
}

- (void)configCustomUI {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.top.equalTo(self).offset(12);
        make.trailing.equalTo(self).offset(-56);
    }];
    
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(28, 28));
        make.top.equalTo(self).offset(12);
        make.trailing.equalTo(self).offset(-12);
    }];
    
    _contentView = [[UIView alloc] init];
    [self addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.leading.equalTo(self).offset(16);
        make.trailing.equalTo(self).offset(-16);
    }];
    
    [_contentView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48, 56));
        make.leading.top.equalTo(_contentView).offset(12);
    }];
    
    [_contentView addSubview:self.dramaTitle];
    [self.dramaTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverImageView.mas_trailing).offset(12);
        make.top.equalTo(self.coverImageView);
        make.trailing.equalTo(_contentView).offset(-12);
    }];
    
    [_contentView addSubview:self.episodeCountLabel];
    [self.episodeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.dramaTitle);
        make.top.equalTo(self.dramaTitle.mas_bottom).offset(2);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorFromHexString:@"#16182314"];
    [_contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(10);
        make.leading.equalTo(_contentView).offset(12);
        make.trailing.equalTo(_contentView).offset(-12);
        make.height.mas_equalTo(1);
    }];
    
    [_contentView addSubview:self.tipImage1];
    [self.tipImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.leading.equalTo(lineView);
        make.top.equalTo(lineView.mas_bottom).offset(12);
    }];
    [_contentView addSubview:self.tipLabel1];
    [self.tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipImage1);
        make.leading.equalTo(self.tipImage1.mas_trailing).offset(2);
    }];
    [_contentView addSubview:self.tipImage2];
    [self.tipImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.equalTo(self.tipImage1);
        make.leading.equalTo(self.tipLabel1.mas_trailing).offset(12);
    }];
    [_contentView addSubview:self.tipLabel2];
    [self.tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipImage2);
        make.leading.equalTo(self.tipImage2.mas_trailing).offset(2);
    }];
    
    [_contentView addSubview:self.payOptionView1];
    [_contentView addSubview:self.payOptionView2];
    [self.payOptionView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLabel1.mas_bottom).offset(35);
        make.leading.equalTo(_contentView).offset(12);
        make.size.mas_equalTo(CGSizeMake(155, 66));
        make.bottom.equalTo(_contentView).offset(-12);
    }];
    [self.payOptionView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.payOptionView1);
        make.trailing.equalTo(_contentView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(155, 66));
        make.bottom.equalTo(self.payOptionView1);
    }];
    
    [self addSubview:self.payButton];
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(12);
        make.trailing.equalTo(self).offset(-12);
        make.height.mas_equalTo(44);
        make.top.equalTo(_contentView.mas_bottom).offset(14);
    }];
}

- (void)onClosePagementPage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClosePaymentView)]) {
        [self.delegate onClosePaymentView];
    }
}

- (void) onClickPayButtonClick {
    if (self.isUnlockAll) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPayAllEpisodes)]) {
            [self.delegate onPayAllEpisodes];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPayEpisodesWithCount:)]) {
            [self.delegate onPayEpisodesWithCount:self.count];
        }
    }
}


- (void)onTabtriggered:(UIGestureRecognizer *)gesture{
    CGPoint touchPoint = [gesture locationInView:self.contentView];
    if (CGRectContainsPoint(self.payOptionView1.frame, touchPoint)) {
        self.isUnlockAll = NO;
        self.price = self.count * 5.0;
    } else if (CGRectContainsPoint(self.payOptionView2.frame, touchPoint)) {
        self.isUnlockAll = YES;
        self.price = self.totalCount * 5.0 * 0.6;
    }
}

- (void)setDramaInfo:(MDDramaInfoModel *)dramaInfo {
    _dramaInfo = dramaInfo;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:dramaInfo.dramaCoverUrl]
                      placeholderImage:[UIImage imageNamed:@"playcover_default" bundleName:@"VodPlayer"]];
    _episodeCountLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_selectView_title", @"MiniDrama"), dramaInfo.dramaLength];
    self.dramaTitle.text = dramaInfo.dramaTitle;

}

- (void)setCount:(NSInteger)count {
    _count = count;
    self.price = count * 5.0;
    UILabel *countLabel = [self viewWithTag:3001];
    UILabel *priceLabel = [self viewWithTag:3002];
    if (countLabel) {
        countLabel.text = [NSString stringWithFormat:@"%ld", self.count];
    }
    if (priceLabel) {
        priceLabel.text = [NSString stringWithFormat:@"USD %.1f", count * 5.0];
    }
}

- (void)setTotalCount:(NSInteger)totalCount {
    _totalCount = totalCount;
    UILabel *priceLabel = [self viewWithTag:3003];
    UILabel *originPriceLabel = [self viewWithTag:3004];
    if (priceLabel) {
        priceLabel.text = [NSString stringWithFormat:@"USD %.1f", totalCount * 5.0 * 0.6];
    }
    if (originPriceLabel) {
        NSString *text = [NSString stringWithFormat:@"(USD%ld)", totalCount * 5];
        NSDictionary *attributes = @{
                NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
                NSStrikethroughColorAttributeName: [UIColor colorFromRGBHexString:@"#161823" andAlpha:0.75 *255],
                NSForegroundColorAttributeName: [UIColor colorFromRGBHexString:@"#161823" andAlpha:0.75 *255],
                NSFontAttributeName: [UIFont boldSystemFontOfSize:12]
            };
        NSAttributedString *atributedStr = [[NSAttributedString  alloc] initWithString:text attributes:attributes];
        originPriceLabel.attributedText = atributedStr;
    }
}

- (void)setPrice:(CGFloat)price {
    _price = price;
    [self.payButton setTitle:[NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_payment_button", @"MiniDrama"),
                              [NSString stringWithFormat:@"%.1f", price]] forState:UIControlStateNormal];
}

- (void)setIsUnlockAll:(BOOL)isUnlockAll {
    _isUnlockAll = isUnlockAll;
    if (isUnlockAll) {
        self.payOptionView1.backgroundColor = [UIColor colorFromRGBHexString:@"#16182308" andAlpha:0.03 * 255];
        self.payOptionView1.layer.borderColor = [[UIColor clearColor] CGColor];
        self.payOptionView2.backgroundColor = [UIColor colorFromRGBHexString:@"#FE2C55" andAlpha:0.04 * 255];
        self.payOptionView2.layer.borderColor = [[UIColor colorFromHexString:@"#FE2C55"] CGColor];
    } else {
        self.payOptionView1.backgroundColor = [UIColor colorFromRGBHexString:@"#FE2C55" andAlpha:0.04 * 255];
        self.payOptionView1.layer.borderColor = [[UIColor colorFromHexString:@"#FE2C55"] CGColor];
        self.payOptionView2.backgroundColor =  [UIColor colorFromRGBHexString:@"#16182308" andAlpha:0.03 * 255];
        self.payOptionView2.layer.borderColor = [[UIColor clearColor] CGColor];
    }
}


#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 12;
        _contentView.backgroundColor = [UIColor colorFromHexString:@"#FFFFFF"];
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#0C0D0E"];
        _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _titleLabel.text = LocalizedStringFromBundle(@"mini_drama_payment_page_title", @"MiniDrama");
        
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(onClosePagementPage) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"ic_close" bundleName:@"ToolKit"] forState:UIControlStateNormal];
        _closeButton.backgroundColor = [UIColor colorFromRGBHexString:@"#D9D9D9" andAlpha: 0.5 *255];
        _closeButton.layer.cornerRadius = 14;
        _closeButton.layer.masksToBounds = YES;
    }
    return _closeButton;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc ] init];
        _coverImageView.layer.cornerRadius = 4;
        _coverImageView.layer.masksToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImageView;
}

- (UILabel *)dramaTitle {
    if (!_dramaTitle) {
        _dramaTitle = [[UILabel alloc] init];
        _dramaTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _dramaTitle.textColor = [UIColor blackColor];
        _dramaTitle.numberOfLines = 2;
    }
    return _dramaTitle;
}

- (UILabel *)episodeCountLabel {
    if (!_episodeCountLabel) {
        _episodeCountLabel = [[UILabel alloc] init];
        _episodeCountLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _episodeCountLabel.textColor = [UIColor colorFromHexString:@"#161823BF"];
    }
    return _episodeCountLabel;
}

- (UILabel *)tipLabel1 {
    if (!_tipLabel1) {
        _tipLabel1 = [[UILabel alloc] init];
        _tipLabel1.textColor = [UIColor colorFromHexString:@"#161823"];
        _tipLabel1.font = [UIFont systemFontOfSize:14];
        _tipLabel1.text = LocalizedStringFromBundle(@"mini_drama_payment_tip1", @"MiniDrama");
    }
    return _tipLabel1;
}

- (UILabel *)tipLabel2 {
    if (!_tipLabel2) {
        _tipLabel2 = [[UILabel alloc] init];
        _tipLabel2.textColor = [UIColor colorFromHexString:@"#161823"];
        _tipLabel2.font = [UIFont systemFontOfSize:14];
        _tipLabel2.text = LocalizedStringFromBundle(@"mini_drama_payment_tip2", @"MiniDrama");
    }
    return _tipLabel2;
}

- (UIImageView *)tipImage1 {
    if (!_tipImage1) {
        _tipImage1 = [[UIImageView alloc] init];
        _tipImage1.image = [UIImage imageNamed:@"circle_empty_right" bundleName:@"MiniDrama"];
    }
    return _tipImage1;
}

- (UIImageView *)tipImage2 {
    if (!_tipImage2) {
        _tipImage2 = [[UIImageView alloc] init];
        _tipImage2.image = [UIImage imageNamed:@"circle_empty_close" bundleName:@"MiniDrama"];
    }
    return _tipImage2;
}

- (UIView *)payOptionView1 {
    if (!_payOptionView1) {
        _payOptionView1 = [[UIView alloc] init];
        _payOptionView1.layer.borderWidth = 1;
        _payOptionView1.layer.cornerRadius = 10;
        UILabel *label1 = [[UILabel alloc] init];
        label1.tag = 3001;
        label1.textColor = [UIColor colorFromHexString:@"#161823"];
        label1.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        UILabel *label2 = [[UILabel alloc] init];
        label2.textColor = [UIColor colorFromHexString:@"#161823"];
        label2.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        UILabel *label3 = [[UILabel alloc] init];
        label3.tag = 3002;
        label3.textColor = [UIColor colorFromHexString:@"#161823"];
        label3.font =  [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        
        label1.text = [NSString stringWithFormat:@"%ld", self.count];
        label2.text = LocalizedStringFromBundle(@"mini_drama_payment_option_episode", @"MiniDrama");
        [_payOptionView1 addSubview:label1];
        [_payOptionView1 addSubview:label2];
        [_payOptionView1 addSubview:label3];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(_payOptionView1).offset(12);
        }];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label1.mas_trailing).offset(2);
            make.bottom.equalTo(label1);
        }];
        [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label1.mas_bottom).offset(2);
            make.leading.equalTo(label1);
            make.trailing.equalTo(_payOptionView1).offset(-12);
        }];
    }
    return _payOptionView1;
}

- (UIView *)payOptionView2 {
    if (!_payOptionView2) {
        _payOptionView2 = [[UIView alloc] init];
        _payOptionView2.layer.borderWidth = 1;
        _payOptionView2.layer.cornerRadius = 10;
        UILabel *label1 = [[UILabel alloc] init];
        label1.textColor = [UIColor colorFromHexString:@"#161823"];
        label1.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        UILabel *label2 = [[UILabel alloc] init];
        label2.textColor = [UIColor colorFromHexString:@"#161823"];
        label2.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        UILabel *label3 = [[UILabel alloc] init];
        label3.textColor = [UIColor colorFromHexString:@"#161823"];
        label3.font =  [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        label3.tag = 3003;
        label1.text = LocalizedStringFromBundle(@"mini_drama_payment_option_all", @"MiniDrama");
        label2.text = LocalizedStringFromBundle(@"mini_drama_payment_option_episode", @"MiniDrama");
        
        UILabel *discountLabel = [[UILabel alloc] init];
        discountLabel.backgroundColor = [UIColor colorFromHexString:@"#FE2C55"];
        discountLabel.textAlignment = NSTextAlignmentCenter;
        discountLabel.textColor = [UIColor whiteColor];
        discountLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        discountLabel.text = @"60%";
        discountLabel.layer.cornerRadius = 4;
        discountLabel.layer.masksToBounds = YES;
        
        UILabel *originPricecLabel = [[UILabel alloc] init];
        originPricecLabel.tag = 3004;
        
        [_payOptionView2 addSubview:label1];
        [_payOptionView2 addSubview:label2];
        [_payOptionView2 addSubview:label3];
        [_payOptionView2 addSubview:discountLabel];
        [_payOptionView2 addSubview:originPricecLabel];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.equalTo(_payOptionView2).offset(12);
        }];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label1.mas_trailing).offset(4);
            make.bottom.equalTo(label1);
        }];
        [discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label2.mas_trailing).offset(2);
            make.size.mas_equalTo(CGSizeMake(31, 16));
            make.bottom.equalTo(label1);
        }];
        [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label1.mas_bottom).offset(2);
            make.leading.equalTo(label1);
        }];
        [originPricecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label3.mas_trailing);
            make.centerY.equalTo(label3);
        }];
    }
    return _payOptionView2;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _payButton.layer.cornerRadius = 8;
        [_payButton addTarget:self action:@selector(onClickPayButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_payButton setBackgroundColor:[UIColor colorFromHexString:@"#FE2C55"]];
    }
    return _payButton;
}

@end
