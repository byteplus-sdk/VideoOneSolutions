// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVMusicReverberationView.h"
#import "KTVMusicReverberationItemView.h"
#import "KTVRTCManager.h"

@interface KTVMusicReverberationView ()

@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, copy) NSArray *dataImageNameList;
@property (nonatomic, copy) NSArray *itemList;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation KTVMusicReverberationView

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
            KTVMusicReverberationItemView *itemView = [[KTVMusicReverberationItemView alloc] init];
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

- (void)itemViewAction:(KTVMusicReverberationItemView *)itemView {
    KTVMusicReverberationItemView *tempItemView = nil;
    for (KTVMusicReverberationItemView *select in self.itemList) {
        select.isSelect = NO;
        if ([select.message isEqualToString:itemView.message]) {
            tempItemView = select;
        }
    }
    if (tempItemView) {
        tempItemView.isSelect = YES;
    }
    
    if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_original")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbOriginal];
    } else if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_echo")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEcho];
    } else if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_concert")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbConcert];
    } else if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_ethereal")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbEthereal];
    } else if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_ktv")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbKTV];
    } else if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_recording_studio")]) {
        [[KTVRTCManager shareRtc] setVoiceReverbType:ByteRTCVoiceReverbStudio];
    } else {
        
    }
}

#pragma mark - Publish Action

- (void)resetItemState:(BOOL)isStartMusic {
    KTVMusicReverberationItemView *defaultItemView = nil;
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        KTVMusicReverberationItemView *itemView = self.contentView.subviews[i];
        if (itemView &&
            [itemView isKindOfClass:[KTVMusicReverberationItemView class]]) {
            if (isStartMusic) {
                if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_ktv")]) {
                    defaultItemView = itemView;
                    break;
                }
            } else {
                if ([itemView.message isEqualToString:LocalizedString(@"reverberation_button_original")]) {
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
        _dataList = @[LocalizedString(@"reverberation_button_original"),
                      LocalizedString(@"reverberation_button_echo"),
                      LocalizedString(@"reverberation_button_concert"),
                      LocalizedString(@"reverberation_button_ethereal"),
                      LocalizedString(@"reverberation_button_ktv"),
                      LocalizedString(@"reverberation_button_recording_studio")];
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
