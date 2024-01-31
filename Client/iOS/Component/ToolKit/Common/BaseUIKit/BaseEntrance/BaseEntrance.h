// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EntranceProtocol <NSObject>

+ (void)prepareEnvironment;

@end

@interface BaseEntrance : NSObject

@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, copy) NSArray<NSString *> *iconNames;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *des;

- (void)enterWithCallback:(void (^)(BOOL result))block;

@end

@interface BaseSceneEntrance : BaseEntrance <EntranceProtocol>

@property (nonatomic, copy) NSString *scenesName;

+ (void)prepareEnvironment;

@end

@interface BaseFunctionEntrance : BaseEntrance

@end

@interface BaseFunctionSection : NSObject {
  @protected
    NSArray<__kindof BaseFunctionEntrance *> *_items;
}

@property (nonatomic, copy, nonnull) NSArray<__kindof BaseFunctionEntrance *> *items;

@end

NS_ASSUME_NONNULL_END
