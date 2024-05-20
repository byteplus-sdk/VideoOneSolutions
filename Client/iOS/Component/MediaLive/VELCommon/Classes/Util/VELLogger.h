// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, VELLogLevel) {
    VELLogLevelOff       = 0,
    VELLogLevelError     = (1 << 0),
    VELLogLevelWarning   = (VELLogLevelError   | (1 << 1)),
    VELLogLevelInfo      = (VELLogLevelWarning | (1 << 2)),
    VELLogLevelDebug     = (VELLogLevelInfo    | (1 << 3)),
    VELLogLevelVerbose   = (VELLogLevelDebug   | (1 << 4)),
    VELLogLevelAll       = NSUIntegerMax
};

@interface VELLogger : NSObject
@property (nonatomic, assign, class) VELLogLevel logLevel;
+ (void)log:(BOOL)asynchronous
        tag:(nullable NSString *)tag
      level:(VELLogLevel)level
       file:(const char *)file
   function:(nullable const char *)function
       line:(int)line
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(7,8);
+ (NSString *)getLogLevelDes:(VELLogLevel)level;
+ (NSArray <NSString *>*)getSorttedLogFiles;
@end

NS_ASSUME_NONNULL_END
