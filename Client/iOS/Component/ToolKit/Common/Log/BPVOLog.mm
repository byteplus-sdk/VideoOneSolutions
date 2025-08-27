// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BPVOLog.h"
#include <os/log.h>
#include <mutex>

NSString * const VOApp = @"VOApp";
NSString * const VOBytePlusLoginKit = @"VOBytePlusLoginKit";
NSString * const VOEffectUIKit = @"VOEffectUIKit";
NSString * const VOInteractiveLive = @"VOInteractiveLive";
NSString * const VOKTV = @"VOKTV";
NSString * const VORTCExample = @"VORTCExample";
NSString * const VOVideoPlayback = @"VOVideoPlayback";
NSString * const VOMediaLive = @"VOMediaLive";
NSString * const VOToolKit = @"VOToolKit";
NSString * const VOTTProto = @"VOTTProto";
NSString *const VOVodPlayer = @"VOVodPlayer";
NSString *const VOMiniDrama = @"VOMiniDrama";
NSString * const VOAIChat = @"VOAIChat";


void __ios_log_print(int prio, const char * __restrict tag, const char * __restrict log) {
    os_log_type_t log_type = OS_LOG_TYPE_DEFAULT;
    char *prioStr = NULL;
    switch (prio) {
        case BPVOLogPriorityError:
            log_type = OS_LOG_TYPE_ERROR;
            prioStr = (char*)"E";
            break;
        case BPVOLogPriorityWarning:
            log_type = OS_LOG_TYPE_ERROR;
            prioStr = (char*)"W";
            break;
        case BPVOLogPriorityInfo:
            log_type = OS_LOG_TYPE_INFO;
            prioStr = (char*)"I";
            break;
        case BPVOLogPriorityDebug:
            log_type = OS_LOG_TYPE_DEBUG;
            prioStr = (char*)"D";
            break;
        case BPVOLogPriorityVerbose:
            log_type = OS_LOG_TYPE_DEBUG;
            prioStr = (char*)"V";
            break;
        default:
            log_type = OS_LOG_TYPE_DEFAULT;
            prioStr = (char*)"";
            break;
    }
   
    os_log_t os_log = os_log_create("com.byteplus.videoone", tag);
    os_log_with_type(os_log, log_type, "%{public}s %{public}s", prioStr, log);
}

void BPVOLog(BOOL force, BPVOLogPriority prio, NSString *tag, const char* file, int line, const char *function, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSMutableString *str = [NSMutableString string];
    if (function != nullptr && strlen(function) > 0) {
        [str appendFormat:@"function: %s, ", function];
    }
    [str appendString:log];
    __ios_log_print((int)prio, tag.UTF8String, str.UTF8String);
}
