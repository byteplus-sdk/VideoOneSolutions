// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFactory.h"
#import "VEEventConst.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceElementDescription.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceContainer.h"
#import "VEMaskView.h"
#import "VEActionButton+Private.h"
#import "VEProgressView+Private.h"
#import "VEDisplayLabel+Private.h"

@implementation VEInterfaceFactory

+ (UIView *)sceneOfMaterial:(id<VEInterfaceElementDataSource>)scene {
    return [self buildingScene:scene];
}

+ (UIView *)elementOfMaterial:(id<VEInterfaceElementDescription>)element scene:(id<VEInterfaceElementDataSource>)scene {
    return [self creatingElement:element scene:scene];
}


#pragma mark ----- Scene

+ (UIView *)buildingScene:(id<VEInterfaceElementDataSource>)obj {
    if ([obj conformsToProtocol:@protocol(VEInterfaceElementDataSource)]) {
        VEInterfaceContainer *interfaceContainer = [[VEInterfaceContainer alloc] initWithScene:obj];
        return interfaceContainer;
    }
    return nil;
}


#pragma mark ----- Element

+ (UIView *)creatingElement:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    if ([obj conformsToProtocol:@protocol(VEInterfaceElementDescription)]) {
        switch (obj.type) {
            case VEInterfaceElementTypeProgressView :
                return [self createProgressView:obj scene:scene];
            case VEInterfaceElementTypeButton :
                return [self createButton:obj scene:scene];
            case VEInterfaceElementTypeLabel :
                return [self createLabel:obj scene:scene];
            case VEInterfaceElementTypeMaskView :
                return [self createMaskView:obj scene:scene];
            case VEInterfaceElementTypeMenuNormalCell :
                break;
            case VEInterfaceElementTypeMenuSwitcherCell :
                break;
            case VEInterfaceElementTypeCustomView :
            default:
                return [self loadCustomView:obj scene:scene];
        }
    }
    return nil;
}


#pragma mark ----- Common

+ (void)loadElementAction:(UIView<VEInterfaceCustomView> *)elementView scene:(id<VEInterfaceElementDataSource>)scene {
    if ([elementView respondsToSelector:@selector(elementViewAction)]) {
        [elementView elementViewAction];
    }
    if (elementView.elementDescription.elementNotify) {
        NSString *mayNotiKey = elementView.elementDescription.elementNotify(elementView, @"", @"");
        void (^keyBlock) (NSString *) = ^(NSString *key) {
            if ([key isKindOfClass:[NSString class]]) {
                SEL selector = @selector(elementViewEventNotify:);
                if ([elementView respondsToSelector:selector]) {
                    [[scene eventMessageBus] registEvent:key withAction:selector ofTarget:elementView];
                }
            }
        };
        if ([mayNotiKey isKindOfClass:[NSArray class]]) {
            NSArray *mayNotiKeys = (NSArray *)mayNotiKey;
            for (NSString *key in mayNotiKeys) {
                keyBlock(key);
            }
        } else {
            keyBlock(mayNotiKey);
        }
    }
}

#pragma mark ----- VEActionButton

+ (UIView *)createButton:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    VEActionButton *button = [VEActionButton buttonWithType:UIButtonTypeCustom];
    button.eventMessageBus = [scene eventMessageBus];
    button.eventPoster = [scene eventPoster];
    button.elementDescription = obj;
    if (obj.elementDisplay) obj.elementDisplay(button);
    [self loadElementAction:button scene:scene];
    return button;
}


#pragma mark ----- VEProgressView

+ (UIView *)createProgressView:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    VEProgressView *progressView = [[VEProgressView alloc] init];
    progressView.eventMessageBus = [scene eventMessageBus];
    progressView.eventPoster = [scene eventPoster];
    progressView.elementDescription = obj;
    [progressView setAutoBackStartPoint:YES];
    [self loadElementAction:progressView scene:scene];
    return progressView;
}


#pragma mark ----- VEDisplayLabel

+ (UIView *)createLabel:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    VEDisplayLabel *label = [VEDisplayLabel new];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15.0];
    if (obj.elementDisplay) obj.elementDisplay(label);
    label.elementDescription = obj;
    [self loadElementAction:label scene:scene];
    return label;
}

#pragma mark ----- VEDisplayLabel

+ (UIView *)createMaskView:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    VEMaskView *maskView = [VEMaskView new];
    maskView.elementDescription = obj;
    [self loadElementAction:maskView scene:scene];
    return maskView;
}

#pragma mark ----- CustomView

+ (UIView *)loadCustomView:(id<VEInterfaceElementDescription>)obj scene:(id<VEInterfaceElementDataSource>)scene {
    UIView<VEInterfaceCustomView> *customView = [obj customView];
    if ([customView isKindOfClass:[UIView class]]) {
        [self loadElementAction:customView scene:scene];
    }
    return customView;
}

@end
