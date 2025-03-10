// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDVideoPlayerController+Observer.h"
#import "MDVideoPlayerController+Tips.h"
#import <Reachability/Reachability.h>
#import <objc/runtime.h>


@implementation MDVideoPlayerController (Observer)

@dynamic needResumePlay;

#pragma mark - Observer

- (void)addObserver {
    [self removeObserver];
    [[Reachability reachabilityForInternetConnection] startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObserver {
    [[Reachability reachabilityForInternetConnection] stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)netStatusChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([Reachability reachabilityForInternetConnection].currentReachabilityStatus) {
            case NotReachable: {
                [self pause];
                [self showTips:NSLocalizedStringFromTable(@"tip_net_not_reachable", @"VodLocalizable", nil)];
            }
                break;
                
            case ReachableViaWiFi: {
                [self play];
                [self showTips:NSLocalizedStringFromTable(@"tip_net_reachable_wifi", @"VodLocalizable", nil)];
            }
                break;
                
            case ReachableViaWWAN: {
                [self play];
                [self showTips:NSLocalizedStringFromTable(@"tip_net_reachable_4g", @"VodLocalizable", nil)];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)applicationEnterBackground {
	if (self.playerConfig.enablePip) {
		return;
	}
    if (self.closeResumePlay) {
        return;
    }
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self pause];
}

- (void)willResignActiveNotification {
	if (self.playerConfig.enablePip) {
		return;
	}
    if (self.closeResumePlay) {
        return;
    }
    if ([self isPlaying]) {
        self.needResumePlay = YES;
        [self pause];
    }
}

- (void)didBecomeActiveNotification {
	if (self.playerConfig.enablePip) {
		return;
	}
    if (self.closeResumePlay) {
        return;
    }
    if (self.needResumePlay) {
        [self play];
    }
    self.needResumePlay = NO;
}

#pragma mark - Setter && Getter

- (BOOL)needResumePlay {
    return [objc_getAssociatedObject(self, @selector(needResumePlay)) boolValue];
}

- (void)setNeedResumePlay:(BOOL)needResumePlay {
    objc_setAssociatedObject(self, @selector(needResumePlay), @(needResumePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)closeResumePlay {
    return [objc_getAssociatedObject(self, @selector(closeResumePlay)) boolValue];
}

- (void)setCloseResumePlay:(BOOL)closeResumePlay {
    objc_setAssociatedObject(self, @selector(closeResumePlay), @(closeResumePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
