//
//  ChorusSongNameLabel.m
//  AFNetworking
//
//  Created by bytedance on 2024/5/29.
//

#import "ChorusSongNameLabel.h"

@interface ChorusSongNameLabel ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ChorusSongNameLabel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(14, 11));
            make.left.equalTo(self);
            make.centerY.equalTo(self);
        }];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(5);
            make.centerY.equalTo(self);
            make.right.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setText:(NSString *)text {
    _text = text;
    
    self.imageView.hidden = IsEmptyStr(text);
    self.label.text = text;
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chorus_prepare_singing_icon" bundleName:HomeBundleName]];
        _imageView.hidden = YES;
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}




@end
