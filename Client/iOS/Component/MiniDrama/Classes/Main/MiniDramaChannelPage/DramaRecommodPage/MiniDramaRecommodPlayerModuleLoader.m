//
//  MiniDramaRecommodPlayerModuleLoader.m
//  MDPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "MiniDramaRecommodPlayerModuleLoader.h"
#import "MDPlayerLoadingModule.h"
#import "MiniDramaPlayButtonModule.h"
#import "MiniDramaPlayerMaskModule.h"
#import "MDPlayerSeekModule.h"
#import "MDPlayerSeekProgressModule.h"
#import "MiniDramaPlayerSpeedModule.h"
#import "MiniDramaRecordStartTimeModule.h"

@interface MiniDramaRecommodPlayerModuleLoader ()

@end

@implementation MiniDramaRecommodPlayerModuleLoader

- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[MiniDramaPlayerMaskModule new]];
    [coreModules addObject:[MDPlayerLoadingModule new]];
    [coreModules addObject:[MiniDramaPlayButtonModule new]];
    [coreModules addObject:[MDPlayerSeekModule new]];
    [coreModules addObject:[MDPlayerSeekProgressModule new]];
//    [coreModules addObject:[MiniDramaRecordStartTimeModule new]];
    return coreModules;
}

@end
