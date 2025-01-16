// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//
#import <Foundation/Foundation.h>
#import "LoggerDefine.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void BPVOLog(BOOL force, BPVOLogPriority prio, NSString *tag, const char* file, int line, const char *function, NSString *format, ...) NS_FORMAT_FUNCTION(7,8) NS_NO_TAIL_CALL;

FOUNDATION_EXPORT NSString * const VOApp;
FOUNDATION_EXPORT NSString * const VOBytePlusLoginKit;
FOUNDATION_EXPORT NSString * const VOEffectUIKit;
FOUNDATION_EXPORT NSString * const VOInteractiveLive;
FOUNDATION_EXPORT NSString * const VOKTV;
FOUNDATION_EXPORT NSString * const VORTCExample;
FOUNDATION_EXPORT NSString * const VOVideoPlayback;
FOUNDATION_EXPORT NSString * const VOMediaLive;
FOUNDATION_EXPORT NSString * const VOToolKit;
FOUNDATION_EXPORT NSString * const VOTTProto;
FOUNDATION_EXPORT NSString * const VOVodPlayer;
FOUNDATION_EXPORT NSString * const VOMiniDrama;


#define VOLogD(tag, format, ...) BPVOLog(NO, BPVOLogPriorityDebug, tag, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define VOLogV(tag, format, ...) BPVOLog(NO, BPVOLogPriorityVerbose, tag, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define VOLogI(tag, format, ...) BPVOLog(NO, BPVOLogPriorityInfo, tag, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define VOLogW(tag, format, ...) BPVOLog(NO, BPVOLogPriorityWarning, tag, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)
#define VOLogE(tag, format, ...) BPVOLog(NO, BPVOLogPriorityError, tag, __FILE__, __LINE__, __FUNCTION__, format, ##__VA_ARGS__)

NS_ASSUME_NONNULL_END
