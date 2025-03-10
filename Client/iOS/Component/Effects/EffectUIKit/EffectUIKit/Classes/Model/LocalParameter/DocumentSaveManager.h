// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocumentSaveManager : NSObject

+ (void)saveLocalJsonToDocument:(NSDictionary *)parameter andKey:(NSString *)key;

+ (NSDictionary *)readLoadLocalJsonWithKey:(NSString *)key;

+ (void)deleteFilesWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
