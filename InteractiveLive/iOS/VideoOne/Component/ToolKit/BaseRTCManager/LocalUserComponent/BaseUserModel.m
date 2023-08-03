// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseUserModel.h"
#import "NetworkingTool.h"

@implementation BaseUserModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uid forKey:@"uid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.loginToken forKey:@"loginToken"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.uid = [coder decodeObjectOfClass:[NSString class] forKey:@"uid"];
        self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.loginToken = [coder decodeObjectOfClass:[NSString class] forKey:@"loginToken"];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"uid" : @"user_id",
             @"name" : @"user_name",
             @"loginToken" : @"login_token"
    };
}

- (void)setUid:(NSString *)uid {
    _uid = uid;
    self.avatarName = [BaseUserModel getAvatarNameWithUid:uid];
}

+ (NSString *)getAvatarNameWithUid:(NSString *)uid {
    if (uid && uid.length > 0) {
        NSInteger index = uid.integerValue % 20;
        return [NSString stringWithFormat:@"avatar%02ld.png", (long)index];
    } else {
        return @"";
    }
    
}
@end
