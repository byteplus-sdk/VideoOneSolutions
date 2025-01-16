//
//  MDPlayFinishStatus.m
//  MDPlayerKit
//

#import "MDPlayFinishStatus.h"

@implementation MDPlayFinishStatus

- (BOOL)playerFinishedSuccess {
    if (!self.error) {
        return YES;
    }
    return NO;
}

@end
