// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectUISlider.h"


@interface EffectUISlider () <UIGestureRecognizerDelegate> {
    BOOL _isShowText;
    BOOL _isInTouch;
    
    CGFloat _width;
    CGFloat _height;
    CGFloat _realPaddingLeft;
    CGFloat _realPaddingRight;
    
    CGFloat _animationSlop;
    CGFloat _animationProgress;
    
    CGFloat _maxTextOffset;
    CGFloat _minTextOffset;
    
    CGFloat _maxTextSize;
    CGFloat _minTextSize;
    
    CGFloat _currentX;
    CGFloat _currentY;
    CGFloat _currentTextOffset;
    CGSize _currentTextSize;
    NSMutableDictionary *_textAttribute;
    NSMutableParagraphStyle *_textStyle;
}
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation EffectUISlider

@synthesize progress = _progress;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaultSize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaultSize];
        [self initSize:frame];
    }
    return self;
}


- (void)initDefaultSize {
    _activeLineColor = [UIColor colorWithWhite:1 alpha:0.75];
    _inactiveLineColor = [UIColor colorWithWhite:0 alpha:0.2];
    _circleColor = [UIColor colorWithWhite:1 alpha:1];
    _textColor = [UIColor colorWithWhite:0.4 alpha:1];
    _lineHeight = 3;
    _circleRadius = 12;
    _textSize = 10;
    _paddingLeft = 5;
    _paddingRight = 5;
    _paddingBottom = 10;
    _textOffset = 30;
    _animationTime = 50;
    
    _progress = 0;
    _negativeable = NO;
    
    _minValue = 0;
    _maxValue = 1.0;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangestureAction:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
}

- (void)initSize:(CGRect)frame {
    _width = frame.size.width;
    _height = frame.size.height;
    
    _realPaddingLeft = _circleRadius/2 + _paddingLeft;
    _realPaddingRight = _circleRadius/2 + _paddingRight;
    
    _minTextOffset = _paddingBottom + _lineHeight / 2;
    _maxTextOffset = _textOffset + _minTextOffset;
    _currentTextOffset = _minTextOffset;
    
    _maxTextSize = _textSize;
    _minTextSize = 0.F;
    
    _animationSlop = 1.F / _animationTime;
    _animationProgress = 0.F;
    
}

# pragma mark - 绘制操作
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.isHidden) {
        return;
    }
    [self checkSize:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, true);
    CGContextClearRect(context, rect);
    
    [self computeSize];
    [self drawLine:context];
    [self drawCircle:context];
    [self drawText:context];
    
    if (_isShowText) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
}

- (void)drawCGLine:(CGContextRef)context rect:(CGRect)rect color:(UIColor*)color
{
    CGContextClipToRect(context, rect);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextMoveToPoint(context, _realPaddingLeft, _currentY);
    CGContextAddLineToPoint(context, _width - _realPaddingRight, _currentY);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextResetClip(context);
}

- (void)drawLine:(CGContextRef)context {
    CGContextSetLineWidth(context, _lineHeight);
    CGContextSetLineCap(context, kCGLineCapRound);
    if(_negativeable) {
        CGRect selectRect = _progress < 0.5?
                            CGRectMake(_currentX, 0, _width/2 - _currentX, _height):
                            CGRectMake( _width/2, 0, _currentX - _width/2, _height);
        
        [self drawCGLine:context rect:CGRectMake(0, 0, _width, _height) color:_inactiveLineColor];
        if(_progress!= 0.5) {
           [self drawCGLine:context rect:selectRect color:_activeLineColor];
        }
    } else {
        CGFloat offset = -_lineHeight / 2 + _lineHeight * _progress;
        // draw left line
        [self drawCGLine:context rect:CGRectMake(0, 0, _currentX + offset, _height) color:_activeLineColor];
        
        // draw right line
        [self drawCGLine:context rect:CGRectMake(_currentX + offset, 0, _width, _height) color:_inactiveLineColor];
    }
}

- (void)drawCircle:(CGContextRef)context {
    CGFloat radius = _isShowText ? MAX(MAX(_currentTextSize.width, _currentTextSize.height), _circleRadius) : _circleRadius;
  
    CGFloat x = _currentX - radius / 2;
    CGFloat y = 0;
    if (self.sliderType == TextSliderTypeAnimated) {
        y = _height - _currentTextOffset - radius / 2;
    } else {
        y = _currentY - radius / 2;
    }
    
    
    CGContextSetFillColorWithColor(context, [_circleColor CGColor]);
    CGContextAddEllipseInRect(context, CGRectMake(x, y, radius, radius));
    
    CGContextDrawPath(context, kCGPathFill);
}

-(void)drawText:(CGContextRef)context {
    if (!_isShowText) {
        return;
    }

    CGFloat x = _currentX - _currentTextSize.width / 2;
    CGFloat y = 0;
    if (self.sliderType == TextSliderTypeAnimated) {
        y = _height - _currentTextOffset - _currentTextSize.height / 2;
    } else {
        y = _currentY - _currentTextSize.height / 2;
    }
    
    NSString *text = self.progressFunc(_progress);
    CGRect rect = CGRectMake(x, y, _currentTextSize.width, _currentTextSize.height);
    [text drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:_textAttribute context:nil];
}

#pragma mark - 监听手势操作

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
    

//    _isInTouch = true;
//    [self performSelector:@selector(startShowText) withObject:nil afterDelay:0];
//
//    UITouch *touch = [touches anyObject];
//    [self dispatchX:[touch locationInView:self].x];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
    

//    UITouch *touch = [touches anyObject];
//    [self dispatchX:[touch locationInView:self].x];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];

//    _isInTouch = false;
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    if ([self.delegate respondsToSelector:@selector(progressEndChange:progress:)])
//    {
//        [self.delegate progressEndChange:self progress:_progress];
//    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesCancelled:touches withEvent:event];

//    _isInTouch = false;
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)pangestureAction:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _isInTouch = true;
        [self performSelector:@selector(startShowText) withObject:nil afterDelay:0];
        [self dispatchX:[gesture locationInView:self].x];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self dispatchX:[gesture locationInView:self].x];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _isInTouch = false;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        if ([self.delegate respondsToSelector:@selector(progressEndChange:progress:)]) {
            [self.delegate progressEndChange:self progress:_progress];
        }
    } else {
        _isInTouch = false;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
//        UIScrollView *tab = (UIScrollView *)[otherGestureRecognizer view];
//        CGPoint bef = [tab.panGestureRecognizer befocityInView:tab];
//        if (bef.y > 0) {
//            CGPoint Point= tab.contentOffset;
//            return Point.y == 0;
//        } else {
//            return NO;
//        }
//    }
    return NO;
}

- (void)startShowText {
    _isShowText = true;
    [self setNeedsDisplay];
}

- (CGFloat)clip:(CGFloat)x {
    if (x < _realPaddingLeft) {
        x = _realPaddingLeft;
    }
    if (x > _width - _realPaddingRight) {
        x = _width - _realPaddingRight;
    }
    return x;
}

- (void)dispatchX:(CGFloat)x {
    x = [self clip:x];
    CGFloat progress = (x - _realPaddingLeft) / (_width - _realPaddingLeft - _realPaddingRight);
    
    if (_progress != progress) {
        _progress = progress;
        _value = _minValue + progress * (_maxValue - _minValue);
        
        if (progress == _minValue || progress == _maxValue) {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
                [generator prepare];
                [generator impactOccurred];
            } else {
                // Fallback on earlier versions
            }
        }
        if ([self.delegate respondsToSelector:@selector(progressDidChange:progress:)]) {
            [self.delegate progressDidChange:self progress:_value];
        }
        if (!_isShowText) {
            [self setNeedsDisplay];
        }
    }
}

- (void)computeSize {
    CGFloat width = _width - _realPaddingLeft - _realPaddingRight;
    _currentX = width * _progress + _realPaddingLeft;
    if (self.sliderType == TextSliderTypeAnimated) {
        _currentY = _height - _paddingBottom - _lineHeight / 2;
    } else {
        _currentY = (_height - _lineHeight) / 2;
    }
    
    if (_isShowText) {
        _animationProgress += _isInTouch ? _animationSlop : -_animationSlop;
        if (_animationProgress > 1) {
            _animationProgress = 1;
        } else if (_animationProgress < 0) {
            _isShowText = false;
            _animationProgress = 0;
        }
        if (self.sliderType == TextSliderTypeAnimated) {
            _currentTextOffset = (_maxTextOffset - _minTextOffset) * _animationProgress + _minTextOffset;
        }
        CGFloat textSize = (_maxTextSize - _minTextSize) * _animationProgress + _minTextSize;
        
        NSString *text = _negativeable ? @(-100).stringValue : @(100).stringValue;
        if (!_textStyle) {
            _textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            _textStyle.alignment = NSTextAlignmentCenter;
        }
        if (!_textAttribute) {
            _textAttribute = [NSMutableDictionary dictionary];
            _textAttribute[NSForegroundColorAttributeName] = _textColor;
            _textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:textSize];
            _textAttribute[NSParagraphStyleAttributeName] = _textStyle;
        } else {
            _textAttribute[NSForegroundColorAttributeName] = _textColor;
            _textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:textSize];
        }
        CGSize size = [text sizeWithAttributes:_textAttribute];
        _currentTextSize = size;
    }
}

- (void)checkSize:(CGRect)rect {
    if (_width != CGRectGetWidth(rect) || _height != CGRectGetHeight(rect)) {
        [self initSize:rect];
    }
}

#pragma mark - setter
- (void)setTextOffset:(CGFloat)textOffset {
    _textOffset = textOffset;
    [self initSize:self.frame];
}

- (void)setTextSize:(CGFloat)textSize {
    _textSize = textSize;
    [self initSize:self.frame];
}

- (void)setCircleRadius:(CGFloat)circleRadius {
    _circleRadius = circleRadius;
    [self initSize:self.frame];
}

- (void)setAnimationTime:(NSInteger)animationTime {
    _animationTime = animationTime;
    [self initSize:self.frame];
}

- (void)setPaddingLeft:(CGFloat)paddingLeft {
    _paddingLeft = paddingLeft;
    [self initSize:self.frame];
}

- (void)setPaddingRight:(CGFloat)paddingRight {
    _paddingRight = paddingRight;
    [self initSize:self.frame];
}

- (void)setPaddingBottom:(CGFloat)paddingBottom {
    _paddingBottom = paddingBottom;
    [self initSize:self.frame];
}

- (void)setValue:(CGFloat)value {
    _value = value;
    [self resetProgress];
}

- (void)setProgress:(CGFloat)progress {
    [self _setProgress:progress];
    _value = _minValue + (_maxValue - _minValue) * progress;
    [self setNeedsDisplay];
}

- (void)_setProgress:(CGFloat)progress {
    if (progress < 0) {
        _progress = 0;
    } else if (progress > 1) {
        _progress = 1;
    } else {
        _progress = progress;
    }
}

- (void)resetProgress {
    [self _setProgress:(_value - _minValue) / (_maxValue - _minValue)];
    [self setNeedsDisplay];
}

- (void)setMinValue:(CGFloat)minValue {
    if (ABS(_minValue - minValue) > 0.01) {
        _minValue = minValue;
        [self resetProgress];
    }
}

- (void)setMaxValue:(CGFloat)maxValue {
    if (ABS(_maxValue - maxValue) > 0.01) {
        _maxValue = maxValue;
        [self resetProgress];
    }
}

- (void)setNegativeable:(BOOL)negativeable {
    _negativeable = negativeable;
    [self setNeedsDisplay];
}

- (NSString*(^)(CGFloat))progressFunc {
    if (!_progressFunc) {
        __weak __typeof(self)weakSelf = self;
        _progressFunc = ^(CGFloat progress) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            CGFloat showValue = strongSelf->_negativeable ? (progress * 100 - 50): progress * 100;
            NSString *text = [[NSString alloc] initWithFormat:@"%d",  (int)showValue];
            return text;
        };
    }
    return _progressFunc;
}
- (void)resetToDefaultMinMaxValue {
    if (_minValue != 0) {
        [self setMinValue:0];
    }
    if (_maxValue != 1) {
        [self setMaxValue:1];
    }
}
@end
