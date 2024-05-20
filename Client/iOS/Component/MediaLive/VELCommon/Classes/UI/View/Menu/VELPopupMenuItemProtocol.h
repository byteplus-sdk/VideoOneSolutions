// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPopupMenuItemProtocol_h
#define VELPopupMenuItemProtocol_h
#import <UIKit/UIKit.h>

@class VELPopupMenuView;

@protocol VELPopupMenuItemProtocol <NSObject>
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, copy, nullable) void (^handler)(__kindof NSObject<VELPopupMenuItemProtocol> *aItem);
@property(nonatomic, weak, nullable) VELPopupMenuView *menuView;
- (void)updateAppearance;
@end

#endif /* VELPopupMenuItemProtocol_h */
