// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceFloater.h"

@interface MDInterfaceDisplayItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, strong) NSString *itemAction;

@property (nonatomic, strong) id actionParam;

@end

@interface MDInterfaceSelectionMenu : UIView <MDInterfaceFloaterPresentProtocol>

@property (nonatomic, strong) NSMutableArray<MDInterfaceDisplayItem *> *items;

@end



