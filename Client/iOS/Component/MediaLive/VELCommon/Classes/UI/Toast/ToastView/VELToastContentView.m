// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELToastContentView.h"
#import "VELCommonDefine.h"
#import "UIView+VELAdd.h"
#define VEL_CUSTOM_VIEW_BOTTOM_MARGIN 8
#define VEL_TEXTLABEL_BOTTOM_MARGIN 4
#define VEL_DETAILTEXTLABEL_BOTTOM_MARGIN 0
@interface VELToastContentView ()
@property(nonatomic, strong, readwrite) VELUILabel *textLabel;
@property(nonatomic, strong, readwrite) VELUILabel *detailTextLabel;
@property (nonatomic, assign) UIEdgeInsets marginInsets;
@end

@implementation VELToastContentView
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault {
    self.marginInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    [self addSubview:self.textLabel];
    [self addSubview:self.detailTextLabel];
}

- (void)setCustomView:(UIView *)customView {
    if (self.customView) {
        [self.customView removeFromSuperview];
        _customView = nil;
    }
    _customView = customView;
    [self addSubview:self.customView];
    [self.superview setNeedsLayout];
}

- (void)setText:(NSString *)text {
    _text = text.copy;
    self.textLabel.text = text;
    [self.superview setNeedsLayout];
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText.copy;
    self.detailTextLabel.text = detailText;
    [self.superview setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    BOOL hasCustomView = !!self.customView;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    CGFloat maxContentWidth = size.width - VELUIEdgeInsetsGetHorizontalValue(self.marginInsets);
    CGFloat maxContentHeight = size.height - VELUIEdgeInsetsGetVerticalValue(self.marginInsets);
    
    if (hasCustomView) {
        width = MIN(maxContentWidth, MAX(width, CGRectGetWidth(self.customView.frame)));
        height += (CGRectGetHeight(self.customView.frame) + VEL_CUSTOM_VIEW_BOTTOM_MARGIN);
    }
    
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = MIN(maxContentWidth, MAX(width, textLabelSize.width));
        height += (textLabelSize.height + VEL_TEXTLABEL_BOTTOM_MARGIN);
    }
    
    if (hasDetailTextLabel) {
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = MIN(maxContentWidth, MAX(width, detailTextLabelSize.width));
        height += (detailTextLabelSize.height + VEL_DETAILTEXTLABEL_BOTTOM_MARGIN);
    }
    
    width += VELUIEdgeInsetsGetHorizontalValue(self.marginInsets);
    height += VELUIEdgeInsetsGetVerticalValue(self.marginInsets);
    
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasCustomView = !!self.customView;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat contentLimitWidth = self.vel_width - VELUIEdgeInsetsGetHorizontalValue(self.marginInsets);
    CGSize contentSize = [self sizeThatFits:self.bounds.size];
    CGFloat minY = self.marginInsets.top + VELCGFloatGetCenter(self.vel_height - VELUIEdgeInsetsGetVerticalValue(self.marginInsets), contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.marginInsets));
    if (hasCustomView) {
        self.customView.vel_left = self.marginInsets.left + VELCGFloatGetCenter(contentLimitWidth, self.customView.vel_width);
        self.customView.vel_top = minY;
        minY = self.customView.vel_bottom + VEL_CUSTOM_VIEW_BOTTOM_MARGIN;
    }
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(contentLimitWidth, CGFLOAT_MAX)];
        self.textLabel.vel_left = self.marginInsets.left;
        self.textLabel.vel_top = minY;
        self.textLabel.vel_width = contentLimitWidth;
        self.textLabel.vel_height = textLabelSize.height;
        minY = self.textLabel.vel_bottom + VEL_TEXTLABEL_BOTTOM_MARGIN;
    }
    if (hasDetailTextLabel) {
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(contentLimitWidth, CGFLOAT_MAX)];
        self.detailTextLabel.vel_left = self.marginInsets.left;
        self.detailTextLabel.vel_top = minY;
        self.detailTextLabel.vel_width = contentLimitWidth;
        self.detailTextLabel.vel_height = detailTextLabelSize.height;
    }
}

- (NSMutableParagraphStyle *)paragraphStyleWithLineHeight:(CGFloat)lineHeight {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return paragraphStyle;
}

- (VELUILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[VELUILabel alloc] init];
        _textLabel.numberOfLines = 0;
        _textLabel.opaque = NO;
        _textLabel.textAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                      NSParagraphStyleAttributeName: [self paragraphStyleWithLineHeight:22],
                                      NSForegroundColorAttributeName : UIColor.whiteColor
        };
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (VELUILabel *)detailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [[VELUILabel alloc] init];
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.opaque = NO;
        _detailTextLabel.textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                            NSParagraphStyleAttributeName: [self paragraphStyleWithLineHeight:18],
                                            NSForegroundColorAttributeName : UIColor.whiteColor
        };
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailTextLabel;
}
@end
