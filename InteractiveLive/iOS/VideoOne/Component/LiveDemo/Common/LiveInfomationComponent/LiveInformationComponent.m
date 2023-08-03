// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInformationComponent.h"
#import "LiveInfomationContentView.h"

@interface LiveInformationComponent ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) LiveInfomationContentView *contentView;
@property (nonatomic, strong) LiveInformationStreamModel *streamModel;

@end

@implementation LiveInformationComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
        _streamModel = [LiveInformationStreamModel new];
    }
    return self;
}

#pragma mark - Publish Action

- (void)show {
    if (![self.linkSession isInteracting]) {
        [[ToastComponent shareToastComponent] showLoading];
    }
    [self.superView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];
    
    CGFloat contentViewHeight = 509;
    [self.superView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.superView);
        make.bottom.equalTo(self.superView).offset(contentViewHeight);
        make.height.mas_equalTo(contentViewHeight);
    }];
    [self.contentView.superview setNeedsLayout];
    [self.contentView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.superView).offset(0);
        }];
        [self.contentView.superview layoutIfNeeded];
    }];
    
    self.contentView.basicDataLists = [self getBasicDataLists];
    self.contentView.realTimeDataLists = [self getRealTimeDataLists];
    WeakSelf;
    self.linkSession.normalPushStreaming.streamLogCallback = ^(NSInteger bitrate, NSDictionary *log, NSDictionary *extra) {
        StrongSelf;
        if ([log[@"event_key"] isEqualToString:@"push_stream"]) {
            [sself.streamModel parseStreamLog:log extra:extra];
            sself.contentView.basicDataLists = [sself getBasicDataLists];
            sself.contentView.realTimeDataLists = [sself getRealTimeDataLists];
            [sself.contentView refresh];
            [[ToastComponent shareToastComponent] dismiss];
        }
    };
}

#pragma mark - Private Action

- (NSArray *)getRealTimeDataLists {    
    BOOL interacting = [self.linkSession isInteracting];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveInfomationModel *model1 = [[LiveInfomationModel alloc] init];
    model1.title = @"Real-time capture FPS";
    model1.value = interacting ? @"0" : [NSString stringWithFormat:@"%ld", self.streamModel.captureFps];
    [list addObject:model1];
    
    LiveInfomationModel *model2 = [[LiveInfomationModel alloc] init];
    model2.title = @"Real-time transmission FPS";
    model2.value = interacting ? @"0" : [NSString stringWithFormat:@"%ld", self.streamModel.transFps];
    [list addObject:model2];
    
    LiveInfomationModel *model3 = [[LiveInfomationModel alloc] init];
    model3.title = @"Real-time encoding bitrate";
    model3.value = interacting ? @"0 kbps" : [NSString stringWithFormat:@"%ld kbps", self.streamModel.realTimeEncodeBitrate];
    model3.isSegmentation = YES;
    [list addObject:model3];
    
    LiveInfomationModel *model4 = [[LiveInfomationModel alloc] init];
    model4.title = @"Real-time transmission bitrate";
    model4.value = interacting ? @"0 kbps" : [NSString stringWithFormat:@"%ld kbps", self.streamModel.realTimeTransBitrate];
    [list addObject:model4];
    
    return [list copy];
}

- (NSArray *)getBasicDataLists {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveInfomationModel *model1 = [[LiveInfomationModel alloc] init];
    model1.title = @"Initial video bitrate";
    model1.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.defaultBitrate/1000];
    [list addObject:model1];
    
    LiveInfomationModel *model2 = [[LiveInfomationModel alloc] init];
    model2.title = @"Maximum video bitrate";
    model2.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.maxBitrate/1000];
    [list addObject:model2];
    
    LiveInfomationModel *model3 = [[LiveInfomationModel alloc] init];
    model3.title = @"Minimum video bitrate";
    model3.value = [NSString stringWithFormat:@"%ld kbps", self.streamModel.minBitrate/1000];
    [list addObject:model3];
    
    LiveInfomationModel *model4 = [[LiveInfomationModel alloc] init];
    model4.title = @"Capture resolution";
    model4.value = self.streamModel.captureResolution;
    model4.isSegmentation = YES;
    [list addObject:model4];
    
    LiveInfomationModel *model5 = [[LiveInfomationModel alloc] init];
    model5.title = @"Push video resolution";
    model5.value = self.streamModel.pushResolution;
    [list addObject:model5];
    
    LiveInfomationModel *model6 = [[LiveInfomationModel alloc] init];
    model6.title = @"Capture FPS";
    model6.value = [NSString stringWithFormat:@"%ld", self.streamModel.captureFps];
    [list addObject:model6];
    
    LiveInfomationModel *model7 = [[LiveInfomationModel alloc] init];
    model7.title = @"Encoding format";
    model7.value = self.streamModel.encodeFormat;
    [list addObject:model7];
    
    LiveInfomationModel *model8 = [[LiveInfomationModel alloc] init];
    model8.title = @"Adaptive Bitrate Mode";
    model8.value = self.streamModel.adaptiveBitrateMode;
    [list addObject:model8];
    
    return [list copy];
}

- (void)dismiss {
    if (self.maskView.superview) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
    
    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
    self.linkSession.normalPushStreaming.streamLogCallback = nil;
    [[ToastComponent shareToastComponent] dismiss];
}

#pragma mark - Getter

- (LiveInfomationContentView *)contentView {
    if (!_contentView) {
        _contentView = [[LiveInfomationContentView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:1 * 255];
    }
    return _contentView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}



@end
