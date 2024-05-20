// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELLogger.h"

#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
#import <CocoaLumberjack/CocoaLumberjack.h>
#define VEL_LOG_USE_DDLOG 1
@interface VELLoggerFormatter : NSObject <DDLogFormatter>
@end
@implementation VELLoggerFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"[%@][VELLogger][%@] %@ %@",
            [VELLogger getLogLevelDes:(VELLogLevel)logMessage.flag],
            logMessage.representedObject,
            logMessage.function,
            logMessage.message];
}

@end

@interface VELLoggerFileFormatter : VELLoggerFormatter
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end
@implementation VELLoggerFileFormatter
- (instancetype)init{
    if (self = [super init]) {
        [self dateFormatter];
    }
    return self;
}
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *dateAndTime = [self.dateFormatter stringFromDate:logMessage->_timestamp];
    return [NSString stringWithFormat:@"%@ %@", dateAndTime, [super formatLogMessage:logMessage]];
}

- (NSDateFormatter *)dateFormatter {
    @synchronized (self) {
        if (!_dateFormatter) {
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_Hans_CN"]];
            [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
            [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSSZ"];
        }
    }
    return _dateFormatter;
}

@end
#endif

static VELLogLevel __log_level__ = VELLogLevelOff;
@implementation VELLogger
+ (void)setLogLevel:(VELLogLevel)logLevel {
    [self setupDDLogIfNeed];
    @synchronized (self) {
        __log_level__ = logLevel;
    }
}

+ (VELLogLevel)logLevel {
    return __log_level__;
}

+ (void)log:(BOOL)asynchronous
        tag:(NSString *)tag
      level:(VELLogLevel)level
       file:(const char *)file
   function:(nullable const char *)function
       line:(int)line
     format:(NSString *)format, ... {
    if (format != nil) {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        va_start(args, format);
        [self log:asynchronous
          message:message
              tag:tag
            level:level
             file:file
         function:function
             line:line];
        va_end(args);
    }
}
+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
        tag:(NSString *)tag
      level:(VELLogLevel)level
       file:(const char *)file
   function:(nullable const char *)function
       line:(int)line  {
    @synchronized (self) {
    if (__log_level__ == VELLogLevelOff || level > __log_level__) {
        return;
    }
        
#if VEL_LOG_USE_DDLOG
    [DDLog log:asynchronous
         level:(DDLogLevel)__log_level__
          flag:(DDLogFlag)level
       context:0
          file:file
      function:function
          line:line
           tag:tag
        format:@"%@", message];
#else
    NSLog(@"[%@][VELLogger][%@] %s %@", [self getLogLevelDes:level], tag, function, message);
#endif
    }
}

+ (NSString *)getLogLevelDes:(VELLogLevel)level {
    switch (level) {
        case VELLogLevelOff: return @"Off";
        case VELLogLevelError: return @"E";
        case VELLogLevelWarning: return @"W";
        case VELLogLevelInfo: return @"I";
        case VELLogLevelDebug: return @"D";
        case VELLogLevelVerbose: return @"V";
        case VELLogLevelAll: return @"A";
    }
    return @"A";
}

+ (void)setupDDLogIfNeed {
#if VEL_LOG_USE_DDLOG
    @synchronized (self) {
        static BOOL isSetupDDLog = NO;
        if (!isSetupDDLog) {
            NSString *logDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"logs"];
            DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDir];
            DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
            fileLogger.logFormatter = [[VELLoggerFileFormatter alloc] init];
            [DDLog addLogger:fileLogger];
#if DEBUG
            if (@available(iOS 10.0, *)) {
                [DDOSLogger sharedInstance].logFormatter = [[VELLoggerFormatter alloc] init];
                [DDLog addLogger:[DDOSLogger sharedInstance]];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [DDASLLogger sharedInstance].logFormatter = [[VELLoggerFormatter alloc] init];
                [DDLog addLogger:[DDASLLogger sharedInstance]];
#pragma clang diagnostic pop
            }
#endif
            isSetupDDLog = YES;
        }
    }
#endif
}

+ (NSArray<NSString *> *)getSorttedLogFiles {
#if VEL_LOG_USE_DDLOG
    @synchronized (self) {
        NSString *logDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"logs"];
        DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDir];
        return [fileManager sortedLogFilePaths];
    }
#else
    return @[];
#endif
}
@end
