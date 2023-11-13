//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface STSToken : NSObject <YYModel>

@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secretAccessKey;
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, copy) NSString *expiredTime;
@property (nonatomic, copy) NSString *currentTime;
@property (nonatomic, copy) NSString *spaceName;

@end

NS_ASSUME_NONNULL_END
