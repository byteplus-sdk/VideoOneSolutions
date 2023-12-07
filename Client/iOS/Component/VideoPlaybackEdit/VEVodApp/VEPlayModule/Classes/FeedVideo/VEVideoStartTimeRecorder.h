//
//  VEVideoStartTimeRecorder.h
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/10/30.
//

#import <Foundation/Foundation.h>



@interface VEVideoStartTimeRecorder : NSObject

+ (instancetype)sharedInstance;

- (void)record:(NSString *)key startTime:(NSTimeInterval)time;

- (NSTimeInterval)startTimeFor:(NSString *)key;

- (void)removeRecord:(NSString *)key;

- (void)cleanCache;


@end


