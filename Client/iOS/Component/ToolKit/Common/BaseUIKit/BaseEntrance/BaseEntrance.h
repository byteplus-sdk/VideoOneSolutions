// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <ToolKit/ToolKit.h>

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
@property (nonatomic, copy) NSArray<NSString *> *desList;

- (void)enterWithCallback:(void (^)(BOOL result))block;

@end

@interface BaseSceneEntrance : BaseEntrance <EntranceProtocol>

@property (nonatomic, copy) NSString *scenesName;

+ (void)prepareEnvironment;

@end

@interface BaseFunctionEntrance : BaseEntrance

// Default is YES
@property (nonatomic, assign) BOOL isNeedShow;
// Default is 8
@property (nonatomic, assign) NSInteger marginTop;
@property (nonatomic, assign) NSInteger marginBottom;
// Default is 58
@property (nonatomic, assign) NSInteger height;

@end

@interface BaseFunctionSection : NSObject {
  @protected
    NSArray<__kindof BaseFunctionEntrance *> *_items;
}

@property (nonatomic, copy, nonnull) NSArray<__kindof BaseFunctionEntrance *> *items;
@property (nonatomic, copy, nullable) NSString *tableSectionName;

@end

@interface BaseFunctionDataList : NSObject {
  @protected
    NSArray<__kindof BaseFunctionSection *> *_items;
}
@property (nonatomic, copy, nonnull) NSArray<__kindof BaseFunctionSection *> *items;

@property (nonatomic, copy) NSString *functionSectionName;

@end

NS_ASSUME_NONNULL_END
