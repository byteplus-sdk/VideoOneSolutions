// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "DocumentSaveManager.h"

@implementation DocumentSaveManager

+ (void)saveLocalJsonToDocument:(NSDictionary *)parameter andKey:(NSString *)key {
    NSArray *documentArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [documentArray lastObject];
    NSString *documnetPath = [document stringByAppendingPathComponent:key];
    NSData *data= [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:documnetPath atomically:YES];
}

+ (NSDictionary *)readLoadLocalJsonWithKey:(NSString *)key {
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [array lastObject];
    NSString *documnetPath = [documents stringByAppendingPathComponent:key];
    NSData *data=[NSData dataWithContentsOfFile:documnetPath];
    if (data) {
        NSDictionary *dictionary =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        return dictionary;
    }else {
        return nil;
    }
    return nil;
}

+ (void)deleteFilesWithKey:(NSString *)key {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [array lastObject];
    NSString *documnetPath = [documents stringByAppendingPathComponent:key];
    [fileManager removeItemAtPath:documnetPath error:NULL];
}

@end
