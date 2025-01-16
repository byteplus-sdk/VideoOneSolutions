//
//  UIView+MDElementDescripition.m
//  MDPlayerUIModule
//
//  Created by real on 2021/09/30.
//

#import "UIView+MDElementDescripition.h"
#import "MDInterfaceElementDescription.h"
#import <objc/message.h>

@implementation UIView (MDElementDescripition)

- (void)setElementDescription:(id<MDInterfaceElementDescription>)elementDescription {
    objc_setAssociatedObject(self, @selector(elementDescription), elementDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<MDInterfaceElementDescription>)elementDescription {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)elementID {
    return [self.elementDescription elementID];
}

@end
