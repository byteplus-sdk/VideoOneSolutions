//
//  MDInterfaceSimpleMethodSceneConf.m
//  MDPlayerUIModule
//
//  Created by real on 2021/12/29.
//

#import "MDInterfaceSimpleMethodSceneConf.h"
#import "MDInterfacePlayElement.h"
#import "MDInterfaceProgressElement.h"

@implementation MDInterfaceSimpleMethodSceneConf

- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements {
    return @[
        [MDInterfacePlayElement playButton],
        [MDInterfacePlayElement playGesture], 
        [MDInterfaceProgressElement progressView],
    ];
}

@end
