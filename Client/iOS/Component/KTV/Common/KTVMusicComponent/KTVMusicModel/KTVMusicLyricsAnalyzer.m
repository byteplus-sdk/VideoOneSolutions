// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVMusicLyricsAnalyzer.h"
#import "KTVMusicLyricModel.h"

@implementation KTVMusicLyricsAnalyzer

+ (KTVMusicLyricModel *)analyzeLrcByPath:(NSString *)path
                               lrcFormat:(KTVMusicLrcFormat)lrcFormat {
    NSError *error;
    // Get json data from the file
    NSString *json = [self analyzeLrcJsonByPath:path error:&error];
    if (error) {
        return nil;
    }
    // Convert json data into an array according to the carriage return "\n".
    NSMutableArray<KTVMusicLyricLineModel *> *lrcLines = [NSMutableArray array];
    NSArray<NSString *> *jsonArray = [json componentsSeparatedByString:@"\n"];
    [jsonArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Parse each line of lyrics according to the encoding format
        KTVMusicLyricLineModel *line = nil;
        if (lrcFormat == KTVMusicLrcFormatKRC) {
            line = [self analyzeLineLrcKRC:obj];
        } else if (lrcFormat == KTVMusicLrcFormatLRC) {
            line = [self analyzeLineLrcLRC:obj];
        } else {
            // error
        }
        if (line) {
            [lrcLines addObject:line];
        }
    }];
    KTVMusicLyricModel *infoModel = [[KTVMusicLyricModel alloc] init];
    infoModel.lines = [lrcLines copy];
    return infoModel;
}

#pragma mark - KRC

/*
  * KRC format analysis
  *
  * [Start time ms, duration ms] <word offset time ms, word duration ms, 0> song
  * [107073,1822]<0,202,0>Lyrics<202,152,0>Lyrics
  */
+ (KTVMusicLyricLineModel *)analyzeLineLrcKRC:(NSString *)lrcLine {
    if (!lrcLine || lrcLine.length <= 0) {
        return nil;
    }
    NSString *lineRegexStr = @"^\\[(\\d+),(\\d+)\\](.*)";
    NSString *wordRegexStr = @"<\\d+,\\d+,\\d+>[^<]+";
    NSString *timeAllRegexStr = @"<\\d+,\\d+,\\d+>";
    NSString *timeRegexStr = @"<(\\d+),(\\d+),(\\d+)>";
    // Parse a line of lyrics
    NSArray *lineList = [self matchString:lrcLine
                              regexString:lineRegexStr];
    if (lineList.count < 4) {
        // Parsing error
        return nil;
    }
    // Lyric text part For example: <0,202,0> can be <202,152,0>
    NSString *lineLrcStr = lineList[3];
    if (lineLrcStr.length <= 0) {
        return nil;
    }
    
    NSMutableArray *wordArray = [[NSMutableArray alloc] init];
    NSMutableArray <KTVMusicLyricWordModel *> *wordModelArray = [[NSMutableArray alloc] init];
    NSArray *wordList = [self matchString:lineLrcStr
                              regexString:wordRegexStr];
    // Parse each character such as [@"<0,151,0>", @"<151,102,0>"]
    NSArray *timList = [self matchString:lineLrcStr
                              regexString:timeAllRegexStr];
    if (timList.count != wordList.count) {
        return nil;
    }
    
    for (int i = 0; i < timList.count; i++) {
        KTVMusicLyricWordModel *wordModel = [[KTVMusicLyricWordModel alloc] init];
        
        // TimeStr @"<0,202,0>"
        NSString *timeStr = timList[i];
        NSArray *timeList = [self matchString:timeStr
                                  regexString:timeRegexStr];
        wordModel.offset = [timeList[1] integerValue];
        wordModel.duration = [timeList[2] integerValue];
        NSString *workStr = [wordList[i] stringByReplacingOccurrencesOfString:timeStr withString:@""];
        wordModel.word = workStr;
        [wordModelArray addObject:wordModel];
        [wordArray addObject:workStr];
    }
    
    KTVMusicLyricLineModel *lyricLineModel = [[KTVMusicLyricLineModel alloc] init];
    lyricLineModel.beginTime = [lineList[1] integerValue];
    lyricLineModel.duration = [lineList[2] integerValue];
    lyricLineModel.content = [wordArray componentsJoinedByString:@""];
    lyricLineModel.words = [wordModelArray copy];
    return lyricLineModel;
}

#pragma mark - LRC

/*
 * Standard lrc format analysis
 *
 * [minute:second.hundredth second]lyrics
 * [02:09.699]I am a line of lyrics
 */
+ (KTVMusicLyricLineModel *)analyzeLineLrcLRC:(NSString *)lrcLine {
    if (!lrcLine || lrcLine.length <= 0) {
        return nil;
    }
    NSString *lineRegexStr = @"^\\[(\\d+):(\\d+).(\\d+)\\](.*)";
    // Parse a line of lyrics
    NSArray *lineList = [self matchString:lrcLine
                              regexString:lineRegexStr];
    if (lineList.count < 5) {
        // Parsing error
        return nil;
    }
    // Lyric text part For example: @"I am a line of lyrics"
    NSString *lineLrcStr = lineList.lastObject;
    if (lineLrcStr.length <= 0) {
        return nil;
    }
    NSInteger minute = [lineList[1] integerValue];
    NSInteger second = [lineList[2] integerValue];
    NSInteger millisecond = [lineList[3] integerValue];
    
    KTVMusicLyricLineModel *lyricLineModel = [[KTVMusicLyricLineModel alloc] init];
    lyricLineModel.beginTime = ((minute * 60 + second) * 1000) + millisecond;
    lyricLineModel.duration = 0;
    lyricLineModel.content = [self htmlEntityDecode:lineLrcStr];;
    lyricLineModel.words = @[];
    return lyricLineModel;
}

#pragma mark - Tool

+ (NSArray *)matchString:(NSString *)string regexString:(NSString *)regexString {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            if (component) {
                [array addObject:component];
            }
        }
    }
    return [array copy];
}

+ (NSString *)analyzeLrcJsonByPath:(NSString *)path
                                       error:(NSError *_Nullable *)error {
    NSError *aerror = nil;
    NSString *string = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:&aerror];
    if (aerror.code == 261) {
        string = [NSString stringWithContentsOfFile:path
                                           encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                              error:&aerror];
    }
    if (error) {
        *error = aerror;
    }
    return string;
}

+ (NSString *)htmlEntityDecode:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return string;
}

@end
