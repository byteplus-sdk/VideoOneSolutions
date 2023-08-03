// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import "LiveGiftEffectModel.h"

@implementation LiveGiftEffectModel

- (instancetype)initWithMessage:(LiveMessageModel *)message sendUserModel:(LiveUserModel *)user {
    self = [super init];
    switch (message.giftType) {
        case 1 : {
            self.sendMessage = @"sent Like";
            self.giftIcon = @"gift_like";
            break;
        }
        case 2: {
            self.sendMessage = @"sent Sugar";
            self.giftIcon = @"gift_sugar";
            break;
        }
        case 3: {
            self.sendMessage = @"sent Diamond";
            self.giftIcon = @"gift_diamond";
            break;
        }
        case 4: {
            self.sendMessage = @"sent Fireworks";
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
