//
//  KTVPickSongTableViewCell.m
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import "KTVPickSongTableViewCell.h"
#import "KTVSongModel.h"
#import "UIImageView+WebCache.h"

@interface KTVPickSongTableViewCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *songLabel;
@property (nonatomic, strong) UILabel *singerLabel;
@property (nonatomic, strong) UIButton *pickButton;
@property (nonatomic, strong) UIView *pickButtonMaskView;
@property (nonatomic, strong) UIView *singingView;

@end

@implementation KTVPickSongTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.songLabel];
    [self.contentView addSubview:self.singerLabel];
    [self.contentView addSubview:self.pickButtonMaskView];
    [self.contentView addSubview:self.pickButton];
    [self.contentView addSubview:self.singingView];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(48);
    }];
    
    [self.songLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.top.equalTo(self.coverImageView).offset(4);
    }];
    
    [self.pickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-16);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(80, 24));
    }];
    
    [self.singerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.bottom.equalTo(self.coverImageView).offset(-4);
        make.right.lessThanOrEqualTo(self.pickButton.mas_left).offset(-2);
    }];
    
    [self.pickButtonMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.pickButton);
    }];
    
    [self.singingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-16);
        make.height.equalTo(@16);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.singingView.hidden = YES;
}

#pragma mark - methods

- (void)setType:(KTVSongListViewType)type {
    _type = type;
    
    self.pickButton.hidden = (type == KTVSongListViewTypePicked);
}

- (void)setSongModel:(KTVSongModel *)songModel {
    _songModel = songModel;
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:songModel.coverURL] placeholderImage:nil];

    self.songLabel.text = songModel.musicName;
    if (self.type == KTVSongListViewTypeOnline) {
        self.singerLabel.text = [NSString stringWithFormat:LocalizedString(@"label_music_list_singer_%@"), songModel.singerUserName];
    } else {
        self.singerLabel.text = [NSString stringWithFormat:LocalizedString(@"label_pick_song_singer_%@"), songModel.pickedUserName];
        self.singingView.hidden = (songModel.singStatus != KTVSongModelSingStatusSinging);
    }
    
    if (songModel.isPicked) {
        [self updatePickButtonHighlight:NO];
        [self.pickButton setTitle:LocalizedString(@"button_music_list_already") forState:UIControlStateNormal];
    } else {
        switch (songModel.status) {
            case KTVSongModelStatusDownloaded:
            case KTVSongModelStatusNormal: {
                [self updatePickButtonHighlight:YES];
                [self.pickButton setTitle:LocalizedString(@"button_music_list_request_song") forState:UIControlStateNormal];
            }
                break;
            case KTVSongModelStatusWaitingDownload: {
                [self updatePickButtonHighlight:NO];
                [self.pickButton setTitle:LocalizedString(@"button_music_list_waiting") forState:UIControlStateNormal];
            }
                break;
            case KTVSongModelStatusDownloading: {
                [self updatePickButtonHighlight:NO];
                [self.pickButton setTitle:LocalizedString(@"button_music_list_downloading") forState:UIControlStateNormal];
            }
                break;            
            default:
                break;
        }
    }
}

- (void)updatePickButtonHighlight:(BOOL)isHighlight {
    if (isHighlight) {
        self.pickButtonMaskView.hidden = NO;
        [self.pickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.pickButton.backgroundColor = UIColor.clearColor;
    } else {
        self.pickButtonMaskView.hidden = YES;
        [self.pickButton setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
        self.pickButton.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255];
    }
}

- (void)pickButtonClick {
    if ((self.songModel.status == KTVSongModelStatusNormal ||
         self.songModel.status == KTVSongModelStatusDownloaded) &&
        !self.songModel.isPicked) {
        if (self.pickSongBlock) {
            self.pickSongBlock(self.songModel);
        }
    }
}

#pragma mark - Getter

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.cornerRadius = 4;
        _coverImageView.layer.masksToBounds = YES;
    }
    return _coverImageView;
}

- (UILabel *)songLabel {
    if (!_songLabel) {
        _songLabel = [[UILabel alloc] init];
        _songLabel.font = [UIFont systemFontOfSize:14];
        _songLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.9 * 255];
    }
    return _songLabel;
}

- (UILabel *)singerLabel {
    if (!_singerLabel) {
        _singerLabel = [[UILabel alloc] init];
        _singerLabel.font = [UIFont systemFontOfSize:10];
        _singerLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.6 * 255];
        _singerLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _singerLabel;
}

- (UIButton *)pickButton {
    if (!_pickButton) {
        _pickButton = [[UIButton alloc] init];
        [_pickButton setTitle:LocalizedString(@"button_music_list_request_song") forState:UIControlStateNormal];
        [_pickButton setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        _pickButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_pickButton addTarget:self action:@selector(pickButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _pickButton.layer.cornerRadius = 2;
        _pickButton.layer.masksToBounds = YES;
        _pickButton.backgroundColor = [UIColor clearColor];
    }
    return _pickButton;
}

- (UIView *)pickButtonMaskView {
    if (!_pickButtonMaskView) {
        _pickButtonMaskView = [[UIView alloc] init];
        _pickButtonMaskView.backgroundColor = [UIColor clearColor];
        _pickButtonMaskView.layer.cornerRadius = 2;
        _pickButtonMaskView.layer.masksToBounds = YES;
        
        CAGradientLayer *pickButtonLayer = [CAGradientLayer layer];
        pickButtonLayer.colors = @[
            (__bridge id)[UIColor colorFromRGBHexString:@"#FF1764"].CGColor,
            (__bridge id)[UIColor colorFromRGBHexString:@"#ED3596"].CGColor
        ];
        pickButtonLayer.frame = CGRectMake(0, 0, 80, 24);
        pickButtonLayer.startPoint = CGPointMake(0.25, 0.5);
        pickButtonLayer.endPoint = CGPointMake(0.75, 0.5);
        
        [_pickButtonMaskView.layer addSublayer:pickButtonLayer];
    }
    return _pickButtonMaskView;
}

- (UIView *)singingView {
    if (!_singingView) {
        _singingView = [[UIView alloc] init];
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.image = [UIImage imageNamed:@"pick_song_singing" bundleName:HomeBundleName];
        [_singingView addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.centerY.equalTo(_singingView);
            make.left.equalTo(_singingView);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalizedString(@"label_pick_song_singing");
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorFromHexString:@"#FF4E75"];
        [_singingView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_singingView);
            make.right.equalTo(_singingView);
            make.left.equalTo(iconImageView.mas_right).offset(8);
        }];
        
        _singingView.hidden = YES;
    }
    return _singingView;
}

@end
