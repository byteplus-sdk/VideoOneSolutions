// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSObject+ToElementDescription.h"
#import "MDInterfaceElementProtocol.h"
#import "UIView+MDElementDescripition.h"

@implementation NSObject (ToElementDescription)

- (MDInterfaceElementDescriptionImp *)elementDescription {
    MDInterfaceElementDescriptionImp *imp = [MDInterfaceElementDescriptionImp new];
    if ([self conformsToProtocol:@protocol(MDInterfaceElementProtocol)]) {
        if ([self respondsToSelector:@selector(elementID)]) {
            imp.elementID = [self performSelector:@selector(elementID)];
        }
        if ([self respondsToSelector:@selector(type)]) {
            imp.type = [[self valueForKeyPath:@"type"] integerValue];
        }
        
        imp.elementAction = ^id(id mayElementView) {
            if ([self respondsToSelector:@selector(elementAction:)]) {
                return [self performSelector:@selector(elementAction:) withObject:mayElementView];
            } else {
                return nil;
            }
        };
        imp.elementNotify = ^id(id mayElementView, NSString *key, id obj) {
            id target = self;
            SEL sel = NSSelectorFromString(@"elementNotify:::");
            if ([target respondsToSelector:sel]) {
                IMP imp = [target methodForSelector:sel];
                void (*func)(id, SEL, id, NSString *, id) = (void *)imp;
                func(target, sel, mayElementView, key, obj);
            }
            if ([self respondsToSelector:@selector(elementSubscribe:)]) {
                return [self performSelector:@selector(elementSubscribe:) withObject:mayElementView];
            } else {
                return nil;
            }
        };
        imp.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            id target = self;
            SEL sel = NSSelectorFromString(@"elementWillLayout:::");
            if ([target respondsToSelector:sel]) {
                IMP imp = [target methodForSelector:sel];
                void (*func)(id, SEL, UIView *, NSSet *, UIView *) = (void *)imp;
                func(target, sel, elementView, elementGroup, groupContainer);
            }
        };
        imp.elementDisplay = ^(UIView *elementView) {
            if ([self respondsToSelector:@selector(elementDisplay:)]) {
                [self performSelector:@selector(elementDisplay:) withObject:elementView];
            }
        };
    }
    return imp;
}

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup {
    for (UIView *aView in viewGroup) {
        if ([aView.elementID isEqualToString:identifier]) {
            return aView;
        }
    }
    return nil;
}


@end

