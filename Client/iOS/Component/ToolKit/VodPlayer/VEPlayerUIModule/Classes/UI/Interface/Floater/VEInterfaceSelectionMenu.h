// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFloater.h"

@interface VEInterfaceDisplayItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, strong) NSString *itemAction;

@property (nonatomic, strong) id actionParam;

@end

@interface VEInterfaceSelectionMenu : UIView <VEInterfaceFloaterPresentProtocol>

@property (nonatomic, strong) NSMutableArray<VEInterfaceDisplayItem *> *items;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
