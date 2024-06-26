// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicReverberationView.h"
#import "ChorusMusicReverberationItemView.h"
#import "ChorusRTCManager.h"

@interface ChorusMusicReverberationView ()

@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) NSArray *dataImageNameList;
@property (nonatomic, copy) NSArray *itemList;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ChorusMusicReverberationView

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat itemViewHight = 89;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.top.bottom.equalTo(self);
        }];
        
        CGFloat width = (50 * self.dataList.count) + ((self.dataList.count - 1) * 20);
        [self.scrollView addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(itemViewHight);
        }];
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.dataList.count; i++) {
            ChorusMusicReverberationItemView *itemView = [[ChorusMusicReverberationItemView alloc] init];
            [itemView addTarget:self action:@selector(itemViewAction:) forControlEvents:UIControlEventTouchUpInside];
            itemView.message = self.dataList[i];
            itemView.imageName = self.dataImageNameList[i];
            [self.contentView addSubview:itemView];
            [list addObject:itemView];
        }
        self.itemList = [list copy];
        
        [list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                       withFixedItemLength:50
                               leadSpacing:16
                               tailSpacing:16];
        [list mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(itemViewHight);
        }];
    }
    return self;
}

- (void)itemViewAction:(ChorusMusicReverberationItemView *)itemView {
    ChorusMusicReverberationItemView *tempItemView = nil;
    for (ChorusMusicReverberationItemView *select in self.itemList) {
        select.isSelect = NO;
        if ([select.message isEqualToString:itemView.message]) {
            tempItemView = select;
        }
    }
    if (tempItemView) {
        tempItemView.isSelect = YES;
    }
    
    if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_original")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    } else if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_echo")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEcho];
    } else if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_concert")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbConcert];
    } else if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_ethereal")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEthereal];
    } else if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_ktv")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbKTV];
    } else if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_recording")]) {
        [[ChorusRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbStudio];
    } else {
        
    }
}

#pragma mark - Publish Action

- (void)resetItemState:(BOOL)isStartMusic {
    ChorusMusicReverberationItemView *defaultItemView = nil;
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        ChorusMusicReverberationItemView *itemView = self.contentView.subviews[i];
        if (itemView &&
            [itemView isKindOfClass:[ChorusMusicReverberationItemView class]]) {
            if (isStartMusic) {
                if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_ktv")]) {
                    defaultItemView = itemView;
                    break;
                }
            } else {
                if ([itemView.message isEqualToString:LocalizedString(@"label_reverberation_original")]) {
                    defaultItemView = itemView;
                    break;
                }
            }
        }
    }
    if (defaultItemView) {
        [self itemViewAction:defaultItemView];
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = @[LocalizedString(@"label_reverberation_original"),
                      LocalizedString(@"label_reverberation_echo"),
                      LocalizedString(@"label_reverberation_concert"),
                      LocalizedString(@"label_reverberation_ethereal"),
                      LocalizedString(@"label_reverberation_ktv"),
                      LocalizedString(@"label_reverberation_recording")];
    }
    return _dataList;
}

- (NSArray *)dataImageNameList {
    if (!_dataImageNameList) {
        _dataImageNameList = @[@"reverberation_button_original",
                               @"reverberation_button_echo",
                               @"reverberation_button_concert",
                               @"reverberation_button_ethereal",
                               @"reverberation_button_ktv",
                               @"reverberation_button_recording_studio"];
    }
    return _dataImageNameList;
}

@end
