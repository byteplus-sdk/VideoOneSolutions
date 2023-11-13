// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportComponent : NSObject

+ (void)blockAndReportUser:(NSString *)userID;

+ (void)blockAndReport:(NSString *)key
                 title:(NSString *)title
         cancelHandler:(void (^__nullable)(void))cancelHandler
       blockCompletion:(void (^__nullable)(void))blockCompletion
      reportCompletion:(void (^__nullable)(void))reportCompletion;

+ (void)showBlockAndReportSheet:(NSString *)key
                          title:(NSString *)title
                  cancelHandler:(void (^__nullable)(void))cancelHandler
                   blockHandler:(void (^__nullable)(void))blockHandler
               reportCompletion:(void (^__nullable)(void))reportCompletion;

+ (void)report:(NSString *)key
    cancelHandler:(void (^__nullable)(void))cancelHandler
       completion:(void (^__nullable)(void))completion;

+ (void)setBlockedKey:(NSString *)blockedKey;

+ (BOOL)containsBlockedKey:(NSString *)blockedKey;

@end

NS_ASSUME_NONNULL_END
