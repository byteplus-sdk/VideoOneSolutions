// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUILabel.h"
#import <ToolKit/Localizator.h>
@interface VELUILabel ()

@property(nonatomic, strong) UIColor *oldBgColor;
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end
@implementation VELUILabel
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textAttributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.blackColor
        };
    }
    return self;
}
- (void)setTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)textAttributes {
    NSDictionary *oldAttributes = [NSDictionary dictionaryWithDictionary:_textAttributes?:@{}];
    
    if ([oldAttributes isEqualToDictionary:textAttributes?:@{}]) {
        return;
    }
    
    _textAttributes = textAttributes;
    
    if (!self.text.length) {
        return;
    }
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    NSRange fullRange = NSMakeRange(0, string.length);
    
    if (oldAttributes.count > 0) {
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:oldAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
                if (oldAttributes[attr] == value) {
                    [willRemovedAttributes addObject:attr];
                }
            }];
        }];
        [willRemovedAttributes enumerateObjectsUsingBlock:^(id  _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
            [string removeAttribute:attr range:fullRange];
        }];
    }
    if (textAttributes) {
        [string addAttributes:textAttributes range:fullRange];
    }
    [self setAttributedText:[self attributedStringWithKernAndLineHeight:string]];
}

- (void)setText:(NSString *)text {
    if (!text || (self.textAttributes.count == 0 && self.lineHeight <= 0)) {
        [super setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.textAttributes];
    [self setAttributedText:[self attributedStringWithKernAndLineHeight:attributedString]];
}

- (void)setAttributedText:(NSAttributedString *)text {
    if (!text || (self.textAttributes.count == 0 && self.lineHeight <= 0)) {
        [super setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeight:attributedString] mutableCopy];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [super setAttributedText:attributedString];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [super setLineBreakMode:lineBreakMode];
    [self reconfigTextAttributes];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self reconfigTextAttributes];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    if (font && self.textAttributes[NSFontAttributeName]) {
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.textAttributes.mutableCopy;
        attrs[NSFontAttributeName] = font;
        self.textAttributes = attrs.copy;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    if (textColor && self.textAttributes[NSForegroundColorAttributeName]) {
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.textAttributes.mutableCopy;
        attrs[NSForegroundColorAttributeName] = textColor;
        self.textAttributes = attrs.copy;
    }
}

- (void)reconfigTextAttributes {
    if (!self.textAttributes) {
        return;
    }
    if (self.textAttributes[NSParagraphStyleAttributeName]) {
        NSMutableParagraphStyle *p = ((NSParagraphStyle *)self.textAttributes[NSParagraphStyleAttributeName]).mutableCopy;
        p.alignment = self.textAlignment;
        p.lineBreakMode = self.lineBreakMode;
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.textAttributes.mutableCopy;
        attrs[NSParagraphStyleAttributeName] = p.copy;
        self.textAttributes = attrs.copy;
    }
}

- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.attributedText.string?:@"" attributes:self.textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeight:attributedString] mutableCopy];
    [self setAttributedText:attributedString];
}

- (CGSize)intrinsicContentSize {
    CGFloat preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;
    if (preferredMaxLayoutWidth <= 0) {
        preferredMaxLayoutWidth = CGFLOAT_MAX;
    }
    return [self sizeThatFits:CGSizeMake(preferredMaxLayoutWidth, CGFLOAT_MAX)];
}

- (UIColor *)backgroundColor {
    return self.oldBgColor;
}

- (void)setCanCopy:(BOOL)canCopy {
    _canCopy = canCopy;
    if (_canCopy && !self.longPressGesture) {
        self.userInteractionEnabled = YES;
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
        [self addGestureRecognizer:self.longPressGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuWillHideNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
    } else if (!_canCopy && self.longPressGesture) {
        [self removeGestureRecognizer:self.longPressGesture];
        self.longPressGesture = nil;
        self.userInteractionEnabled = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (BOOL)canBecomeFirstResponder {
    return self.canCopy;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([self canBecomeFirstResponder]) {
        return action == @selector(copyString:);
    }
    return NO;
}

- (void)copyString:(id)sender {
    if (self.canCopy) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *stringToCopy = self.text;
        if (stringToCopy) {
            pasteboard.string = stringToCopy;
            if (self.didCopyBlock) {
                self.didCopyBlock(self, stringToCopy);
            }
        }
    }
}

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.canCopy) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:LocalizedStringFromBundle(@"medialive_copy", @"MediaLive") action:@selector(copyString:)];
        [[UIMenuController sharedMenuController] setMenuItems:@[copyMenuItem]];
        [menuController setTargetRect:self.frame inView:self.superview];
        [menuController setMenuVisible:YES animated:YES];
        
        self.highlighted = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        self.highlighted = NO;
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    if (!self.canCopy) {
        return;
    }
    
    [self setHighlighted:NO];
}

- (NSAttributedString *)attributedStringWithKernAndLineHeight:(NSAttributedString *)string {
    if (!string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString = (NSMutableAttributedString *)string;
    } else {
        attributedString = [string mutableCopy];
    }
    if (self.textAttributes[NSKernAttributeName]) {
        [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    }
    __block BOOL shouldAdjustLineHeight = self.lineHeight > 0;
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
        if (NSEqualRanges(range, NSMakeRange(0, attributedString.length))) {
            if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                shouldAdjustLineHeight = NO;
                *stop = YES;
            }
        }
    }];
    if (shouldAdjustLineHeight) {
        NSMutableParagraphStyle *paraStyle = [self paragraphStyleWithLineHeight:self.lineHeight lineBreakMode:self.lineBreakMode textAlignment:self.textAlignment];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length)];
        CGFloat baselineOffset = (self.lineHeight - self.font.lineHeight) / 4;
        [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset) range:NSMakeRange(0, attributedString.length)];
    }
    
    return attributedString;
}

- (NSMutableParagraphStyle *)paragraphStyleWithLineHeight:(CGFloat)lineHeight
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                            textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
