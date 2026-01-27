// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEPlayModel.h"
#import "NSString+VE.h"

@implementation VEPlayModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return  @{
        @"vid": @"vid",
        @"coverUrl": @"cover",
        @"playAuthToken": @"playAuthToken"
    };
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (VEPlayModel *)playModelWithLocalFileUrl:(NSString *)fileUrl {
    VEPlayModel *model = [VEPlayModel new];
    model.type = 1;
    model.httpUrl = fileUrl;
    model.md5Key = [fileUrl vloc_md5String];
    return model;
}

+ (VEPlayModel *)playModelWithRemoteUrl:(NSString *)remoteUrl {
    VEPlayModel *model = [VEPlayModel new];
    model.type = 1;
    model.httpUrl = remoteUrl;
    model.md5Key = [remoteUrl vloc_md5String];
    return model;
}

+ (VEPlayModel *)playModelWithRemoteUrls:(NSArray<NSString *> *)remoteUrls {
    if (remoteUrls.count == 0) {
        return nil;
    }
    VEPlayModel *model = [VEPlayModel new];
    model.type = 1;
    model.urlArray = remoteUrls.copy;
    model.md5Key = [remoteUrls.firstObject vloc_md5String];
    return model;
}

@end
