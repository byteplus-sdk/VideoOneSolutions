// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceFactory.h"
#import "MDEventConst.h"
#import "MDInterfaceProtocol.h"
#import "MDInterfaceElementDescription.h"
#import "UIView+MDElementDescripition.h"
#import "MDInterfaceContainer.h"
#import "MDActionButton+Private.h"
#import "MDProgressView+Private.h"
#import "MDDisplayLabel+Private.h"

@implementation MDInterfaceFactory

+ (UIView *)sceneOfMaterial:(id<MDInterfaceElementDataSource>)scene {
    return [self buildingScene:scene];
}

+ (UIView *)elementOfMaterial:(id<MDInterfaceElementDescription>)element {
    return [self creatingElement:element];
}


#pragma mark ----- Scene

+ (UIView *)buildingScene:(id<MDInterfaceElementDataSource>)obj {
    if ([obj conformsToProtocol:@protocol(MDInterfaceElementDataSource)]) {
        MDInterfaceContainer *interfaceContainer = [[MDInterfaceContainer alloc] initWithScene:obj];
        return interfaceContainer;
    }
    return nil;
}


#pragma mark ----- Element

+ (UIView *)creatingElement:(id<MDInterfaceElementDescription>)obj {
    if ([obj conformsToProtocol:@protocol(MDInterfaceElementDescription)]) {
        switch (obj.type) {
            case MDInterfaceElementTypeProgressView : {
                return [self createProgressView:obj];
            }
                break;
            case MDInterfaceElementTypeButton : {
                return [self createButton:obj];
            }
                break;
            case MDInterfaceElementTypeLabel : {
                return [self createLabel:obj];
            }
                break;
            case MDInterfaceElementTypeMenuNormalCell : {
                
            }
                break;
            case MDInterfaceElementTypeMenuSwitcherCell : {
                
            }
                break;
            case MDInterfaceElementTypeCustomView :
            default: {
                return [self loadCustomView:obj];
            }
        }
    }
    return nil;
}


#pragma mark ----- Common

+ (void)loadElementAction:(UIView<MDInterfaceCustomView> *)elementView {
    if ([elementView respondsToSelector:@selector(elementViewAction)]) {
        [elementView elementViewAction];
    }
    if (elementView.elementDescription.elementNotify) {
        NSString *mayNotiKey = elementView.elementDescription.elementNotify(elementView, @"", @"");
        void (^keyBlock) (NSString *) = ^(NSString *key) {
            if ([key isKindOfClass:[NSString class]]) {
                SEL selector = @selector(elementViewEventNotify:);
                if ([elementView respondsToSelector:selector]) {
                    [[MDEventMessageBus universalBus] registEvent:key withAction:selector ofTarget:elementView];
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

#pragma mark ----- MDActionButton

+ (UIView *)createButton:(id<MDInterfaceElementDescription>)obj {
    MDActionButton *button = [MDActionButton buttonWithType:UIButtonTypeCustom];
    button.elementDescription = obj;
    if (obj.elementDisplay) obj.elementDisplay(button);
    [self loadElementAction:button];
    return button;
}


#pragma mark ----- MDProgressView

+ (UIView *)createProgressView:(id<MDInterfaceElementDescription>)obj {
    MDProgressView *progressView = [MDProgressView new];
    progressView.elementDescription = obj;
    [progressView setAutoBackStartPoint:YES];
    [self loadElementAction:progressView];
    return progressView;
}


#pragma mark ----- MDDisplayLabel

+ (UIView *)createLabel:(id<MDInterfaceElementDescription>)obj {
    MDDisplayLabel *label = [MDDisplayLabel new];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15.0];
    if (obj.elementDisplay) obj.elementDisplay(label);
    label.elementDescription = obj;
    [self loadElementAction:label];
    return label;
}


#pragma mark ----- CustomView

+ (UIView *)loadCustomView:(id<MDInterfaceElementDescription>)obj {
    UIView<MDInterfaceCustomView> *customView = [obj customView];
    customView.elementDescription = obj;
    if (obj.elementDisplay) obj.elementDisplay(customView);
    if ([customView isKindOfClass:[UIView class]]) {
        [self loadElementAction:customView];
    }
    return customView;
}

@end
