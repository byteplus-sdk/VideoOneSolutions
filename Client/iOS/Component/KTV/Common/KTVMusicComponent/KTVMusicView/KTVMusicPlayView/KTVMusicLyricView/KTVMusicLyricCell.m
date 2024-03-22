//
//  KTVMusicLyricCell.m
//  AFNetworking
//
//  Created by bytedance on 2022/11/21.
//

#import "KTVMusicLyricCell.h"
#import "KTVMusicLyricLabel.h"

@interface KTVMusicLyricCell ()

@property (nonatomic, strong) KTVMusicLyricLabel *messageLabel;
@property (nonatomic, strong) UIScrollView *mainScrollerView;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, assign) NSInteger currentRow;
@property (nonatomic, assign) NSInteger playingRow;
@property (nonatomic, assign) CGFloat lineWidth;

@end

@implementation KTVMusicLyricCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style 
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mainScrollerView];
        [self.mainScrollerView addSubview:self.messageLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.mainScrollerView.contentOffset = CGPointZero;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isKRC = self.config.lrcFormat == KTVMusicLrcFormatKRC;
    CGFloat messageLabelWidth = isKRC ? self.lineWidth : self.contentView.bounds.size.width;
    CGFloat cellHeight = isKRC ? 25 : self.contentView.bounds.size.height;
    CGFloat scrollViewX = isKRC ? 10 : 0;
    [self.mainScrollerView setFrame:CGRectMake(scrollViewX,
                                               (self.contentView.bounds.size.height - cellHeight) * 0.5,
                                               self.contentView.bounds.size.width - scrollViewX * 2,
                                               cellHeight)];
    CGFloat offsetX = 0;
    if (self.mainScrollerView.frame.size.width < messageLabelWidth) {
        self.mainScrollerView.contentSize = CGSizeMake(messageLabelWidth, cellHeight);
    } else {
        self.mainScrollerView.contentSize = CGSizeMake(self.bounds.size.width - 2 * scrollViewX, cellHeight);
        offsetX = (self.mainScrollerView.contentSize.width - messageLabelWidth) * 0.5;
        self.mainScrollerView.contentOffset = CGPointMake(0, 0);
    }
    [self.messageLabel setFrame:CGRectMake(offsetX, 0, messageLabelWidth, cellHeight)];
}

#pragma mark - Publish Action

- (void)setLineModel:(KTVMusicLyricLineModel *)lineModel {
    _lineModel = lineModel;
    [self.messageLabel setText:lineModel.content];
}

- (void)setConfig:(KTVMusicLyricConfig *)config {
    _config = config;
    [self.messageLabel setPlayingColor:config.playingColor];
}

- (void)setCurrentRow:(NSInteger)currentRow playingRow:(NSInteger)playingRow {
    _currentRow = currentRow;
    _playingRow = playingRow;

    self.messageLabel.textColor = self.config.normalColor ?: UIColor.whiteColor;
    UIFont *font = self.config.playingFont ?: [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    self.messageLabel.font = font;
    self.lineWidth = [self.lineModel calculateContentWidth:font content:self.lineModel.content];
    
    BOOL isKRC = self.config.lrcFormat == KTVMusicLrcFormatKRC;
    if ((currentRow - playingRow) == 0) {
        if (isKRC) {
            self.messageLabel.progress = _currentProgress;
        } else {
            self.messageLabel.progress = 0;
            self.messageLabel.textColor = self.config.playingColor;
        }
    } else {
        if (isKRC) {
            self.messageLabel.progress = 0;
        } else {
            self.messageLabel.progress = 0;
            self.messageLabel.textColor = self.config.normalColor;
        }
    }
}

- (void)playProgress:(NSInteger)time {
    CGFloat progress = [self.lineModel calculateCurrentLrcProgress:time];
    _currentProgress = progress;
    [self.messageLabel setProgress:progress];
    [self updateTextScrollViewOffset:progress];
}

+ (CGFloat)getCellHeight:(KTVMusicLyricLineModel *)lineModel 
                  config:(KTVMusicLyricConfig *)config
                maxWidth:(CGFloat)maxWidth {
    return [lineModel calculateContentHeight:config.playingFont
                                     content:lineModel.content
                                    maxWidth:maxWidth];
}

#pragma mark - Private Action

- (void)updateTextScrollViewOffset:(CGFloat)progress {
    CGFloat location = self.messageLabel.bounds.size.width * progress;
    if (self.messageLabel.bounds.size.width > 0 && location > self.mainScrollerView.bounds.size.width / 3) {
        CGFloat width = (self.messageLabel.bounds.size.width - self.mainScrollerView.bounds.size.width) + 16;
        CGFloat offsetX = location - self.mainScrollerView.bounds.size.width / 3;
        if (offsetX <= width) {
            [self.mainScrollerView setContentOffset:CGPointMake(offsetX, 0)];
        }
    }
}

#pragma mark - Getter
- (KTVMusicLyricLabel *)messageLabel {
  if (!_messageLabel) {
      _messageLabel = [[KTVMusicLyricLabel alloc] init];
      _messageLabel.numberOfLines = 0;
      _messageLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _messageLabel;
}

- (UIScrollView *)mainScrollerView {
  if (!_mainScrollerView) {
      _mainScrollerView = [[UIScrollView alloc] init];
  }
  return _mainScrollerView;
}

@end
