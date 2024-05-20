// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUITextView.h"
#import "VELCommonDefine.h"

@interface VELUITextView ()
@property(nonatomic, assign) BOOL isSettingTextByShouldChange;
@property(nonatomic, assign) BOOL shouldRejectSystemScroll;
@property(nonatomic, strong) UILabel *placeholderLabel;
@end

@implementation VELUITextView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.scrollsToTop = NO;
    self.placeholderMargins = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.placeholderLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextChanged:)
                                                 name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isCurrentTextDifferentOfText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    if ([textBeforeChange isEqualToString:text] || (textBeforeChange.length == 0 && !text)) {
        return NO;
    }
    return YES;
}

- (void)setText:(NSString *)text {
    if (![self isCurrentTextDifferentOfText:text]) {
        [super setText:text];
        return;
    }
    [super setText:text];
    [self handleTextChanged:self];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (![self isCurrentTextDifferentOfText:attributedText.string]) {
        [super setAttributedText:attributedText];
        return;
    }
    [super setAttributedText:attributedText];
    [self handleTextChanged:self];
}

- (void)setTypingAttributes:(NSDictionary<NSString *,id> *)typingAttributes {
    [super setTypingAttributes:typingAttributes];
    [self updatePlaceholderStyle];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updatePlaceholderStyle];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self updatePlaceholderStyle];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updatePlaceholderStyle];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.attributedText = placeholder ? [[NSAttributedString alloc] initWithString:_placeholder attributes:self.typingAttributes] : nil;
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
    [self updatePlaceholderLabelHidden];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}

- (void)updatePlaceholderStyle {
    self.placeholder = self.placeholder;
}

- (void)updatePlaceholderLabelHidden {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;
    }
}

- (CGRect)preferredPlaceholderFrameWithSize:(CGSize)size {
    if (self.placeholder.length <= 0) return CGRectZero;
    UIEdgeInsets adjustedContentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        adjustedContentInset = self.adjustedContentInset;
    }
    UIEdgeInsets allInsets = self.allInsets;
    UIEdgeInsets labelMargins = UIEdgeInsetsMake(allInsets.top - adjustedContentInset.top, allInsets.left - adjustedContentInset.left, allInsets.bottom - adjustedContentInset.bottom, allInsets.right - adjustedContentInset.right);
    CGFloat limitWidth = size.width - (allInsets.left + allInsets.right);
    CGFloat limitHeight = size.height - (allInsets.top + allInsets.bottom);
    CGSize labelSize = [self.placeholderLabel sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
    labelSize.width = limitWidth == CGFLOAT_MAX ? MIN(limitWidth, labelSize.width) : limitWidth;
    labelSize.height = MIN(limitHeight, labelSize.height);
    return CGRectMake(labelMargins.left, labelMargins.top, labelSize.width, labelSize.height);
}

- (void)handleTextChanged:(id)sender {
    VELUITextView *textView = nil;
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (VELUITextView *)object;
        }
    } else if ([sender isKindOfClass:[VELUITextView class]]) {
        textView = (VELUITextView *)sender;
    }
    
    if (!textView || !textView.window) {
        return;
    }
    
    if (self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
    if (textView.undoManager.undoing || textView.undoManager.redoing) {
        return;
    }
    
    if (!textView.editable) {
        return;
    }
    
    textView.shouldRejectSystemScroll = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        textView.shouldRejectSystemScroll = NO;
        [textView scrollCaretVisibleAnimated:YES];
    });
}

- (void)scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(self.bounds)) return;
    
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    [self _scrollRectToVisible:caretRect animated:animated];
}

- (void)_scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    if (!VELCGRectIsValidated(rect)) {
        return;
    }
    
    CGFloat contentOffsetY = self.contentOffset.y;
    
    BOOL canScroll = self.canScroll;
    UIEdgeInsets adjustedContentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        adjustedContentInset = self.adjustedContentInset;
    }
    if (canScroll) {
        if (CGRectGetMinY(rect) < contentOffsetY + self.textContainerInset.top) {
            contentOffsetY = CGRectGetMinY(rect) - self.textContainerInset.top - adjustedContentInset.top;
        } else if (CGRectGetMaxY(rect) > contentOffsetY + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - adjustedContentInset.bottom) {
            contentOffsetY = CGRectGetMaxY(rect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + adjustedContentInset.bottom;
        }
        CGFloat contentOffsetWhenScrollToTop = -adjustedContentInset.top;
        CGFloat contentOffsetWhenScrollToBottom = self.contentSize.height + adjustedContentInset.bottom - CGRectGetHeight(self.bounds);
        contentOffsetY = MAX(MIN(contentOffsetY, contentOffsetWhenScrollToBottom), contentOffsetWhenScrollToTop);
    } else {
        contentOffsetY = -adjustedContentInset.top;
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}

- (BOOL)canScroll {
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return NO;
    }
    BOOL canVerticalScroll = NO;
    BOOL canHorizontalScoll = NO;
    if (@available(iOS 11.0, *)) {
        canVerticalScroll = self.contentSize.height + (self.adjustedContentInset.top + self.adjustedContentInset.bottom) > CGRectGetHeight(self.bounds);
        canHorizontalScoll = self.contentSize.width + (self.adjustedContentInset.left + self.adjustedContentInset.right) > CGRectGetWidth(self.bounds);
    } else {
        canVerticalScroll = self.contentSize.height > CGRectGetHeight(self.bounds);
        canHorizontalScoll = self.contentSize.width > CGRectGetWidth(self.bounds);
    }
    return canVerticalScroll || canHorizontalScoll;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width <= 0) size.width = CGFLOAT_MAX;
    if (size.height <= 0) size.height = CGFLOAT_MAX;
    CGSize result = CGSizeZero;
    if (self.placeholder.length > 0 && self.text.length <= 0) {
        UIEdgeInsets allInsets = self.allInsets;
        CGRect frame = [self preferredPlaceholderFrameWithSize:size];
        result.width = CGRectGetWidth(frame) + (allInsets.left + allInsets.right);
        result.height = CGRectGetHeight(frame) + (allInsets.top + allInsets.bottom);
    } else {
        result = [super sizeThatFits:size];
    }
    return result;
}

- (UIEdgeInsets)allInsets {
    UIEdgeInsets adjustedContentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        adjustedContentInset = self.adjustedContentInset;
    }
    return VELUIEdgeInsetsConcat(VELUIEdgeInsetsConcat(VELUIEdgeInsetsConcat(self.textContainerInset, self.placeholderMargins), UIEdgeInsetsMake(0, 5, 0, 5)), adjustedContentInset);
}

- (void)setFrame:(CGRect)frame {
    frame = VELCGRectFlatted(frame);
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    if (!sizeChanged) {
        self.shouldRejectSystemScroll = YES;
    }
    [super setFrame:frame];
    if (!sizeChanged) {
        self.shouldRejectSystemScroll = NO;
    }
}

- (void)setBounds:(CGRect)bounds {
    bounds = VELCGRectFlatted(bounds);
    [super setBounds:bounds];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0) {
        CGRect frame = [self preferredPlaceholderFrameWithSize:self.bounds.size];
        self.placeholderLabel.frame = frame;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updatePlaceholderLabelHidden];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return string.length;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset animated:animated];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset];
    }
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.textColor = self.placeholderColor;
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.alpha = 0;
    }
    return _placeholderLabel;
}
@end
