// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GiftType) {
    LiveGiftItemLike = 1,
    LiveGiftItemSugar = 2,
    LiveGiftItemDiamond = 3,
    LiveGiftItemFireworks = 4
};

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftModel : NSObject

@property (nonatomic, copy) NSString *giftIcon;

@property (nonatomic, copy) NSString *giftName;

@property (nonatomic, assign) GiftType giftType;

@end

NS_ASSUME_NONNULL_END
