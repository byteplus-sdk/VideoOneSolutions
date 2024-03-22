//
//  KTVMusicLyricLabel.m
//  AFNetworking
//
//  Created by bytedance on 2022/11/21.
//

#import "KTVMusicLyricLabel.h"

@interface KTVMusicLyricLabel ()

@property (nonatomic, strong) UIColor *textShadowColor;

@property (nonatomic, assign) BOOL style;

@end

@implementation KTVMusicLyricLabel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.style = YES;
        _playingColor = [UIColor whiteColor];
        _textShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.progress <= 0) {
        return;
    }
    
    NSInteger numberOfLines = CGRectGetHeight(self.bounds) / self.font.lineHeight;
    numberOfLines = MAX(numberOfLines, 1);
    
    CGFloat paddingTop = (CGRectGetHeight(self.bounds) - numberOfLines * self.font.lineHeight) / 2;
    CGFloat maxWidth = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, self.font.lineHeight * 2)].width;
    CGFloat oneLineProgress = (maxWidth <= CGRectGetWidth(self.bounds)) ? 1 : CGRectGetWidth(self.bounds) / maxWidth;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (NSInteger index = 0; index < numberOfLines; index++) {
        CGFloat leftProgress = fmin(self.progress, 1) - index * oneLineProgress;
        CGRect fillRect;
        
        if (leftProgress >= oneLineProgress) {
            fillRect = CGRectMake(0, paddingTop + index * self.font.lineHeight, CGRectGetWidth(self.bounds), self.font.lineHeight);
            CGPathAddRect(path, NULL, fillRect);
        } else if (leftProgress > 0) {
            if ((index != numberOfLines - 1) || (maxWidth <= CGRectGetWidth(self.bounds))) {
                fillRect = CGRectMake(0, paddingTop + index * self.font.lineHeight, maxWidth * leftProgress, self.font.lineHeight);
            } else {
                NSInteger newMaxWidth = maxWidth * 1000000;
                NSInteger newSizeWidth = CGRectGetWidth(self.bounds) * 1000000;
                NSInteger z = newMaxWidth % newSizeWidth;
                CGFloat width = z / 1000000.0;
                CGFloat dw = (CGRectGetWidth(self.bounds) - width) / 2 + maxWidth * leftProgress;
                fillRect = CGRectMake(0, paddingTop + index * self.font.lineHeight, dw, self.font.lineHeight);
            }
            
            CGPathAddRect(path, NULL, fillRect);
            break;
        }
    }
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    if (!CGPathIsEmpty(path)) {
        CGContextAddPath(contextRef, path);
        CGContextClip(contextRef);
        
        UIColor *originalTextColor = self.textColor;
        self.textColor = self.playingColor;
        
        if (self.style) {
            CGSize originalShadowOffset = self.shadowOffset;
            UIColor *originalShadowColor = self.textShadowColor;
            
            self.shadowOffset = CGSizeMake(0, 1);
            self.textShadowColor = self.textShadowColor;
            
            [super drawRect:rect];
            
            self.shadowOffset = originalShadowOffset;
            self.textShadowColor = originalShadowColor;
        } else {
            [super drawRect:rect];
        }
        
        self.textColor = originalTextColor;
        CGPathRelease(path);
    }
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        [self setNeedsDisplay];
    }
    _progress = progress;
}

@end
