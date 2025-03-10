// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceVisual.h"
#import "MDInterfaceProtocol.h"
#import "MDInterfaceElementDescription.h"
#import "UIView+MDElementDescripition.h"
#import "MDInterfaceFactory.h"

#import "MDEventConst.h"
#import <Masonry/Masonry.h>

static const CGFloat topAreaHeightRate = 0.3;
static const CGFloat leftAreaWidthRate = 0.3;
static const CGFloat bottomAreaHeightRate = 0.3;
static const CGFloat rightAreaWidthRate = 0.3;

static inline CGFloat allAreaWidth () {
    return UIScreen.mainScreen.bounds.size.width;
}

static inline CGFloat allAreaHeight () {
    return (allAreaWidth() * 9.0 / 16.0);
}

NSString *const MDPlayEventChangePlaySpeed = @"MDPlayEventChangePlaySpeed";

NSString *const MDPlayEventChangeResolution = @"MDPlayEventChangeResolution";

NSString *const MDUIEventScreenClearStateChanged = @"MDUIEventScreenClearStateChanged";

@interface MDInterfaceVisual ()

@property (nonatomic, strong) NSMutableSet *elementViews;

@property (nonatomic, strong) id<MDInterfaceElementDataSource> scene;

@end

@implementation MDInterfaceVisual

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeAreas:scene];
        [self registEvents];
        
    }
    return self;
}

- (void)initializeAreas:(id<MDInterfaceElementDataSource>)scene {
    self.elementViews = [NSMutableSet set];
    self.scene = scene;
    for (id<MDInterfaceElementDescription> elementDes in [scene customizedElements]) {
        if (elementDes.type > MDInterfaceElementTypeVisual) {
            UIView *elementView = [MDInterfaceFactory elementOfMaterial:elementDes];
            [self.elementViews addObject:elementView];
            [self addSubview:elementView];
        }
    }
    [self layoutAreas:self.elementViews ofScene:scene];
}

- (void)layoutAreas:(NSSet *)elementViews ofScene:(id<MDInterfaceElementDataSource>)scene {
    for (UIView *view in elementViews) {
        view.elementDescription.elementWillLayout(view, elementViews, self);
    }
}

#pragma mark ----- Action / Message

- (void)registEvents {
    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenOrientationChanged withAction:@selector(screenOrientationChangedAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenClearStateChanged withAction:@selector(screenStateChangedAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenLockStateChanged withAction:@selector(screenStateChangedAction:) ofTarget:self];
}

- (void)screenOrientationChangedAction:(id)param { 
    [self layoutAreas:self.elementViews ofScene:self.scene];
}

- (void)screenStateChangedAction:(id)param  {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        NSString *key = paramDic.allKeys.firstObject;
        for (UIView *view in self.elementViews) {
            if (view.elementDescription.elementNotify) {
                view.elementDescription.elementNotify(view, key, @"");
            }
        }
    }
}


#pragma mark ----- Response Chain

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView<MDInterfaceCustomView> *elementView in self.elementViews) {
        if ([elementView isEnableZone:point]) {
            return [super hitTest:point withEvent:event];
        }
    }
    return nil;
}

@end
