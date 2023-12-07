// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceVisual.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceElementDescription.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceFactory.h"

#import "VEEventConst.h"
#import "Masonry.h"

const CGFloat topAreaHeightRate = 0.3;
const CGFloat leftAreaWidthRate = 0.3;
const CGFloat bottomAreaHeightRate = 0.3;
const CGFloat rightAreaWidthRate = 0.3;

static inline CGFloat allAreaWidth (void) {
    return UIScreen.mainScreen.bounds.size.width;
}

static inline CGFloat allAreaHeight (void) {
    return (allAreaWidth() * 9.0 / 16.0);
}

NSString *const VEPlayEventChangePlaySpeed = @"VEPlayEventChangePlaySpeed";

NSString *const VEPlayEventChangeResolution = @"VEPlayEventChangeResolution";

NSString *const VEUIEventScreenClearStateChanged = @"VEUIEventScreenClearStateChanged";

@interface VEInterfaceVisual ()

@property (nonatomic, strong) NSMutableSet *elementViews;

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@end

@implementation VEInterfaceVisual

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeAreas:scene];
        [self registEvents];
        
    }
    return self;
}

- (void)initializeAreas:(id<VEInterfaceElementDataSource>)scene {
    self.elementViews = [NSMutableSet set];
    self.scene = scene;
    for (id<VEInterfaceElementDescription> elementDes in [scene customizedElements]) {
        if (elementDes.type > VEInterfaceElementTypeVisual) {
            UIView *elementView = [VEInterfaceFactory elementOfMaterial:elementDes scene:scene];
            [self.elementViews addObject:elementView];
            [self addSubview:elementView];
        }
    }
    [self layoutAreas:self.elementViews ofScene:scene];
}

- (void)layoutAreas:(NSSet *)elementViews ofScene:(id<VEInterfaceElementDataSource>)scene {
    for (UIView *view in elementViews) {
        view.elementDescription.elementWillLayout(view, elementViews, self);
    }
}

#pragma mark ----- Action / Message

- (void)registEvents {
    [self.scene.eventMessageBus registEvent:VEUIEventScreenOrientationChanged withAction:@selector(screenOrientationChangedAction:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEUIEventScreenClearStateChanged withAction:@selector(screenStateChangedAction:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEUIEventScreenLockStateChanged withAction:@selector(screenStateChangedAction:) ofTarget:self];
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
                view.elementDescription.elementNotify(view, key, [paramDic valueForKey:key] ?: @"");
            }
        }
    }
}


#pragma mark ----- Response Chain

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView<VEInterfaceCustomView> *elementView in self.elementViews) {
        if ([elementView isEnableZone:point]) {
            return [super hitTest:point withEvent:event];
        }
    }
    return nil;
}

@end
