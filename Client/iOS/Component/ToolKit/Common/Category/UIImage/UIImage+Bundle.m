// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseUserModel.h"
#import "UIImage+Bundle.h"

@implementation UIImage (Bundle)

#pragma mark - Publish Action

+ (nullable UIImage *)imageNamed:(NSString *)name
                      bundleName:(NSString *)bundle {
    if (name == nil || name.length <= 0) {
        return nil;
    }
    if (bundle == nil || bundle.length <= 0) {
        UIImage *iamge = [UIImage imageNamed:name];
        return iamge;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundle ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    UIImage *image = [UIImage imageNamed:name
                                inBundle:resourceBundle
           compatibleWithTraitCollection:nil];
    return image;
}

+ (nullable UIImage *)imageNamed:(NSString *)name
                      bundleName:(NSString *)bundle
                   subBundleName:(NSString *)subBundleName {
    if (name == nil || name.length <= 0) {
        return nil;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundle ofType:@"bundle"];
    NSBundle *demoBundle = [NSBundle bundleWithPath:bundlePath];

    NSString *subPath = [demoBundle pathForResource:subBundleName ofType:@"bundle"];
    NSBundle *subBundle = [NSBundle bundleWithPath:subPath];
    UIImage *image = [UIImage imageNamed:name
                                inBundle:subBundle
           compatibleWithTraitCollection:nil];
    return image;
}

+ (UIImage *)avatarImageForUid:(NSString *)uid {
    NSString *imageName = [BaseUserModel getAvatarNameWithUid:uid];
    if (!imageName || imageName.length == 0) {
        imageName = @"avatar00.png";
    }
    return [UIImage imageNamed:imageName bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

@end
