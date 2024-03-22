//
//  KTVSeatView.m
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import "KTVSeatView.h"
#import "KTVSeatItemView.h"

static const NSInteger MaxNumber = 6;

@interface KTVSeatView ()

@property (nonatomic, strong) NSMutableArray<KTVSeatItemView *> *itemViewLists;
@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, copy) NSDictionary *volumeDic;
@end

@implementation KTVSeatView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviewAndConstraints];
        __weak __typeof(self) wself = self;
        [self.timer start:0.6 block:^(BOOL result) {
            [wself timerMethod];
        }];
    }
    return self;
}

- (void)setSeatList:(NSArray<KTVSeatModel *> *)seatList {
    _seatList = seatList;
    
    for (int i = 0; i < self.itemViewLists.count; i++) {
        KTVSeatItemView *itemView = self.itemViewLists[i];
        if (i < seatList.count) {
            itemView.seatModel = seatList[i];
        } else {
            itemView.seatModel = nil;
        }
    }
}

- (void)addSeatModel:(KTVSeatModel *)seatModel {
    KTVSeatItemView *selectItemView = nil;
    for (KTVSeatItemView *itemView in self.itemViewLists) {
        if (itemView.index == seatModel.index) {
            selectItemView = itemView;
            break;
        }
    }
    if (selectItemView) {
        selectItemView.seatModel = seatModel;
    }
}

- (void)removeUserModel:(KTVUserModel *)userModel {
    KTVSeatItemView *deleteItemView = nil;
    for (KTVSeatItemView *itemView in self.itemViewLists) {
        if ([itemView.seatModel.userModel.uid isEqualToString:userModel.uid]) {
            deleteItemView = itemView;
            break;
        }
    }
    if (deleteItemView) {
        KTVSeatModel *seatModel = deleteItemView.seatModel;
        seatModel.userModel = nil;
        deleteItemView.seatModel = seatModel;
    }
}

- (void)updateSeatModel:(KTVSeatModel *)seatModel {
    KTVSeatItemView *updateItemView = nil;
    for (KTVSeatItemView *itemView in self.itemViewLists) {
        if (itemView.index == seatModel.index) {
            updateItemView = itemView;
            break;
        }
    }
    if (updateItemView) {
        updateItemView.seatModel = seatModel;
    }
}

- (void)updateSeatVolume:(NSDictionary *)volumeDic {
    _volumeDic = volumeDic;
}

- (void)updateCurrentSongModel:(KTVSongModel *)songModel {
    for (KTVSeatItemView *itemView in self.itemViewLists) {
        [itemView updateCurrentSongModel:songModel];
    }
}

#pragma mark - Private Action

- (void)timerMethod {
    if (_volumeDic.count > 0) {
        for (KTVSeatItemView *itemView in self.itemViewLists) {
            KTVSeatModel *tempSeatModel = itemView.seatModel;
            NSNumber *volumeValue = _volumeDic[tempSeatModel.userModel.uid];
            if (NOEmptyStr(tempSeatModel.userModel.uid) &&
                volumeValue.floatValue > 0) {
                tempSeatModel.userModel.volume = volumeValue.floatValue;
            } else {
                tempSeatModel.userModel.volume = 0;
            }
            itemView.seatModel = tempSeatModel;
        }
    }
}

- (void)addSubviewAndConstraints {
    CGFloat space = (SCREEN_WIDTH - 32 * 7 - 1)/9;
    for (int i = 0; i < MaxNumber; i++) {
        KTVSeatItemView *itemView = [[KTVSeatItemView alloc] init];
        itemView.frame = CGRectMake((32+space)*i, 0, 32, 54);
        itemView.index = i + 1;
        [self addSubview:itemView];
        [self.itemViewLists addObject:itemView];
        
        __weak __typeof(self) wself = self;
        itemView.clickBlock = ^(KTVSeatModel *seatModel) {
            if (wself.clickBlock) {
                wself.clickBlock(seatModel);
            }
        };
    }
}

#pragma mark - Getter

- (NSMutableArray<KTVSeatItemView *> *)itemViewLists {
    if (!_itemViewLists) {
        _itemViewLists = [[NSMutableArray alloc] init];
    }
    return _itemViewLists;
}

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

@end
