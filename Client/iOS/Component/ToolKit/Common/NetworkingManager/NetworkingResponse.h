// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingTool.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingResponse : NSObject

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign, readonly) BOOL result;

@property (nonatomic, copy) id response;

@property (nonatomic, strong, nonnull) NSError *error;

+ (instancetype)dataToResponseModel:(id _Nullable)data;

+ (instancetype)badServerResponse;

+ (instancetype)responseWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
