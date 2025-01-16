//
//  MiniDramaCarouselPageControl.m
//  Pods
//
//  Created by ByteDance on 2024/11/15.
//

#import "MiniDramaCarouselPageControl.h"
#import <Masonry/Masonry.h>

@interface MiniDramaCarouselPageControl ()

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *pageLayers;
@property (nonatomic, assign) CGFloat currentIndicatorWidth;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, assign) CGFloat indicatorSpacing;
@property (nonatomic, assign) CGColorRef indicatorColor;
@property (nonatomic, assign) CGColorRef currentIndicatorColor;

@end

@implementation MiniDramaCarouselPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndicatorWidth = 20;
        _indicatorWidth = 12;
        _indicatorHeight = 4;
        _indicatorSpacing = 4;
        _indicatorColor = [UIColor colorWithWhite:1 alpha:0.4].CGColor;
        _currentIndicatorColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages{
    _numberOfPages = numberOfPages;
    for (CAShapeLayer* layer in _pageLayers) {
        [layer removeFromSuperlayer];
    }

    _pageLayers = [NSMutableArray array];
    for (int i = 0; i < numberOfPages; i++) {
        CAShapeLayer* layer = [[CAShapeLayer alloc]init];
        [self.layer addSublayer:layer];
        [_pageLayers addObject:layer];
    }
    _currentPage = 0;
    [self refreshLayers];
}

- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
    [self refreshLayers];
}

- (void)refreshLayers{
    CGFloat x = (self.bounds.size.width - _indicatorWidth * (_pageLayers.count - 1) - _currentIndicatorWidth - _indicatorSpacing * (_numberOfPages - 1)) * 0.5;
    CGFloat y = (self.bounds.size.height - _indicatorHeight) * 0.5;

    CGFloat xOffset = 0;
    for (int i = 0; i < _numberOfPages; i++) {
        CAShapeLayer* layer = _pageLayers[i];
        if (!layer || !layer.superlayer) {
            continue;
        }
        layer.cornerRadius = 2;
        if (i == _currentPage) {
            layer.backgroundColor = _currentIndicatorColor;
            CGRect frame = CGRectMake(x + xOffset, y, _currentIndicatorWidth, _indicatorHeight);
            layer.frame = frame;
            xOffset += _indicatorSpacing + _currentIndicatorWidth;
        } else {
            CGRect frame = CGRectMake(x + xOffset, y, _indicatorWidth, _indicatorHeight);
            layer.backgroundColor = _indicatorColor;
            layer.frame = frame;
            xOffset += _indicatorSpacing + _indicatorWidth;
        }
    }
}

@end
