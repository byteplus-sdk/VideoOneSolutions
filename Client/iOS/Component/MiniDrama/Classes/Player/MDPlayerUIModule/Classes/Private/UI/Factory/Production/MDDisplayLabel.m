//
//  MDDisplayLabel.m
//  MDPlayerUIModule
//
//  Created by real on 2021/11/9.
//

#import "MDDisplayLabel.h"
#import "UIView+MDElementDescripition.h"
#import "MDInterfaceElementDescription.h"

@implementation MDDisplayLabel

#pragma mark ----- MDInterfaceFactoryProduction

- (void)elementViewAction {
    
}

- (void)elementViewEventNotify:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
