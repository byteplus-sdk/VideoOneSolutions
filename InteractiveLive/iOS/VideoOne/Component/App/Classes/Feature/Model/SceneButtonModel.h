// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneButtonModel : NSObject
@property (nonatomic, copy) NSArray <NSString *> *iconNames;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *bgName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, copy) NSString *scenesName;
@property (nonatomic, strong) NSObject *scenes;
@property (nonatomic, assign) BOOL isNew;
@end

NS_ASSUME_NONNULL_END
