// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftEffectModel.h"
#import <Foundation/Foundation.h>

@implementation LiveGiftEffectModel
- (instancetype)initWithMessage:(LiveMessageModel *)message sendUserModel:(LiveUserModel *)user {
    self = [super init];
    switch (message.giftType) {
        case 1 : {
            self.sendMessage = LocalizedString(@"sent_gift_like");
            self.giftIcon = @"gift_like";
            break;
        }
        case 2: {
            self.sendMessage = LocalizedString(@"sent_gift_sugar");
            self.giftIcon = @"gift_sugar";
            break;
        }
        case 3: {
            self.sendMessage = LocalizedString(@"sent_gift_diamond");
            self.giftIcon = @"gift_diamond";
            break;
        }
        case 4: {
            self.sendMessage = LocalizedString(@"sent_gift_fireworks");
            self.giftIcon = @"gift_fireworks";
            break;
        }
        default: {
            self.sendMessage = @"";
            break;
        }
    }
    self.count = message.count;
    self.userName = user.name;
    self.userAvatar = user.avatarName;
    return self;
}

@end
