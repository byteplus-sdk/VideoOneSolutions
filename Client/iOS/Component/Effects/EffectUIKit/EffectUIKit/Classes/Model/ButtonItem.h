// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>


@interface ButtonItem : NSObject

- (instancetype)initWithSelectImg:(NSString *)selectImg
                      unselectImg:(NSString *)unselectImg
                            title:(NSString *)title
                             desc:(NSString *)desc;

@property (nonatomic, strong) NSString *selectImg;

@property (nonatomic, strong) NSString *unselectImg;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *desc;

@property (nonatomic, strong) NSString *tipTitle;

@property (nonatomic, strong) NSString *tipDesc;

+ (instancetype)modelWithJson:(id)json;

+ (NSArray *)modelArrayWithJson:(id)json;

+ (NSDictionary *)modelContainerPropertyGenericClass;
@end
