//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceCommentCell.h"
#import "VECommentModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface _VEShortVideoFunctionItem : UIControl

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, nullable, copy) UIImage *image;

@property (nonatomic, nullable, copy) NSString *title;

@end

@implementation _VEShortVideoFunctionItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(4);
            make.leading.equalTo(self).offset(6);
            make.trailing.equalTo(self).offset(-6);
            make.size.mas_equalTo(20);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom);
            make.bottom.centerX.equalTo(self);
            make.height.mas_equalTo(16);
        }];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

#pragma mark----- Lazy Load
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor colorWithRed:0.502 green:0.514 blue:0.541 alpha:1];
    }
    return _titleLabel;
}

@end

NSString *const VEInterfaceCommentCelLightID = @"VEInterfaceCommentCelLightID";

NSString *const VEInterfaceCommentCelDarkID = @"VEInterfaceCommentCelDarkID";

@interface VEInterfaceCommentCell ()

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) _VEShortVideoFunctionItem *likeButton;

@end

@implementation VEInterfaceCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self.contentView addGestureRecognizer:recognizer];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(16);
            make.top.equalTo(self.contentView).offset(14);
            make.size.mas_equalTo(36);
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(12);
            make.trailing.lessThanOrEqualTo(self.contentView).offset(-56);
            make.height.mas_equalTo(16);
        }];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(1);
            make.leading.equalTo(self.nameLabel);
            make.trailing.lessThanOrEqualTo(self.contentView).offset(-56);
            make.height.mas_greaterThanOrEqualTo(20);
        }];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_bottom).offset(4);
            make.leading.equalTo(self.nameLabel);
            make.bottom.equalTo(self.contentView).offset(-4);
            make.height.mas_equalTo(16);
        }];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.timeLabel.mas_trailing).offset(12);
            make.centerY.equalTo(self.timeLabel);
            make.height.mas_equalTo(24);
        }];
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(12);
            make.trailing.equalTo(self.contentView).offset(-12);
        }];
    }
    return self;
}

- (void)setComment:(VECommentModel *)comment {
    _comment = comment;
    [self reloadContent];
}

- (void)reloadContent {
    self.avatarView.image = [UIImage avatarImageForUid:self.comment.uid];
    self.nameLabel.text = self.comment.name;
    self.contentLabel.text = self.comment.content;
    self.timeLabel.text = self.comment.createTime;
    self.deleteButton.hidden = ![self.comment.uid isEqualToString:[LocalUserComponent userModel].uid];
    [self reloadLikeButton];
}

- (void)reloadLikeButton {
    self.likeButton.image = [UIImage imageNamed:self.comment.isSelfLiked ? @"vod_liked" : @"vod_like_hollow"];
    self.likeButton.title = [NSString stringForCount:self.comment.likeCount];
}

- (void)likeAction {
    self.comment.selfLiked = !self.comment.isSelfLiked;
    if (self.comment.selfLiked) {
        self.comment.likeCount += 1;
    } else {
        self.comment.likeCount -= 1;
    }
    [self reloadLikeButton];
}

- (void)deleteAction {
    if (self.deleteComment && self.comment) {
        self.deleteComment(self.comment);
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.longPressComment && self.comment) {
            self.longPressComment(self.comment);
        }
    }
}

#pragma mark----- Lazy load

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = 18;
        [self.contentView addSubview:_avatarView];
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor colorWithRed:0.502 green:0.514 blue:0.541 alpha:1];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        if ([self.reuseIdentifier isEqualToString:VEInterfaceCommentCelLightID]) {
            _contentLabel.textColor = [UIColor colorWithRed:0.01 green:0.03 blue:0.08 alpha:1];
        } else {
            _contentLabel.textColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.94 alpha:1];
        }
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor colorWithRed:0.502 green:0.514 blue:0.541 alpha:1];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (_VEShortVideoFunctionItem *)likeButton {
    if (!_likeButton) {
        _likeButton = [[_VEShortVideoFunctionItem alloc] init];
        [_likeButton addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likeButton];
    }
    return _likeButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        [_deleteButton setTitleColor:[UIColor colorWithRed:0.31 green:0.35 blue:0.41 alpha:1.0] forState:UIControlStateNormal];
        [_deleteButton setTitle:LocalizedStringFromBundle(@"delete", @"VEVodApp") forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage imageNamed:@"vod_delete_14"] forState:UIControlStateNormal];
        [_deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
    }
    return _deleteButton;
}

@end
