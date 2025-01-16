//
//  MDVideoPlayerController+Observer.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "MDVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MDVideoPlayerController (Observer)

@property (nonatomic, assign) BOOL needResumePlay;

@property (nonatomic, assign) BOOL closeResumePlay;

- (void)addObserver;

- (void)removeObserver;

@end

NS_ASSUME_NONNULL_END
