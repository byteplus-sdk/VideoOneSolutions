// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftEffectModel.h"
#import <ToolKit/Localizator.h>

@implementation LiveGiftEffectModel
- (instancetype)initWithMessage:(LiveMessageModel *)message sendUserModel:(BaseUserModel *)user {
    self = [super init];
    switch (message.giftType) {
        case 1 : {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_like", @"LiveRoomUI");
            self.giftIcon = @"gift_like";
            break;
        }
        case 2: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_sugar", @"LiveRoomUI");
            self.giftIcon = @"gift_sugar";
            break;
        }
        case 3: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_diamond", @"LiveRoomUI");
            self.giftIcon = @"gift_diamond";
            break;
        }
        case 4: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_fireworks", @"LiveRoomUI");
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

- (instancetype)initWithMessage:(LiveMessageModel *)message {
    self = [super init];
    switch (message.giftType) {
        case 1 : {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_like", @"LiveRoomUI");
            self.giftIcon = @"gift_like";
            break;
        }
        case 2: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_sugar", @"LiveRoomUI");
            self.giftIcon = @"gift_sugar";
            break;
        }
        case 3: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_diamond", @"LiveRoomUI");
            self.giftIcon = @"gift_diamond";
            break;
        }
        case 4: {
            self.sendMessage = LocalizedStringFromBundle(@"sent_gift_fireworks", @"LiveRoomUI");
            self.giftIcon = @"gift_fireworks";
            break;
        }
        default: {
            self.sendMessage = @"";
            break;
        }
    }
    self.count = message.count;
    self.userName = message.userName;
    self.userAvatar = [BaseUserModel getAvatarNameWithUid:message.userId];
    return self;
}

@end
