//
//  MiniDramaIntroduceView.m
//  JSONModel
//

#import "MiniDramaIntroduceView.h"
#import <Masonry/Masonry.h>
#import "MDDramaFeedInfo.h"
#import <ToolKit/ToolKit.h>

@interface MiniDramaIntroduceView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation MiniDramaIntroduceView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo {
    self.titleLabel.text = [NSString stringWithFormat:@"@%@",dramaVideoInfo.videoInfo.authorName];
    self.desLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_list_cell_title", @"MiniDrama"),
                          dramaVideoInfo.dramaInfo.dramaTitle,
                          dramaVideoInfo.videoInfo.order,
                          dramaVideoInfo.videoInfo.videoTitle];
}

- (void)configuratoinCustomView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.desLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - lazy load

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor whiteColor];
        _desLabel.font = [UIFont systemFontOfSize:15];
        _desLabel.numberOfLines = 3;
    }
    return _desLabel;
}

@end
