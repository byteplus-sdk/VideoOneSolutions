// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VeLiveBroadcaseExtensionUILauncher.h"
#import <ReplayKit/ReplayKit.h>

API_AVAILABLE(ios(12.0))
@interface VeLiveBroadcaseExtensionUILauncher()
@property (strong, nonatomic) RPSystemBroadcastPickerView* sysBroacastPicker;
@end

@implementation VeLiveBroadcaseExtensionUILauncher

static  NSString *ExtensionKeyName = @"NSExtension";
static  NSString *ExtensionIdentify = @"NSExtensionPointIdentifier";
static  NSString *AppUpLoaderKey = @"com.apple.broadcast-services-upload";

+ (void)launch:(NSString *)groupBundleId {
    VeLiveBroadcaseExtensionUILauncher *extensionLauncher = [[VeLiveBroadcaseExtensionUILauncher alloc]
                                                             initWithAppGroup:groupBundleId];
    [extensionLauncher launch];
}

- (instancetype)initWithAppGroup:(NSString *)groupBundleId {
    self = [super init];
    if (self) {
        RPSystemBroadcastPickerView* broadCastPicker =
                [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _sysBroacastPicker = broadCastPicker;
        
        if (groupBundleId && [groupBundleId isKindOfClass:NSString.class] && groupBundleId.length > 0) {
            broadCastPicker.preferredExtension = groupBundleId;
        } else {
            NSString *plugInsPath = NSBundle.mainBundle.builtInPlugInsPath;
            if (plugInsPath) {
                NSArray* dirContents = [NSFileManager.defaultManager
                                        contentsOfDirectoryAtPath:plugInsPath
                                        error:nil];
                for (NSString* content in dirContents) {
                    NSURL* fileUrl = [NSURL fileURLWithPath:plugInsPath];
                    NSBundle* bundle = [NSBundle bundleWithPath:[fileUrl URLByAppendingPathComponent:content].path];
                    NSDictionary* extension = [bundle.infoDictionary objectForKey:ExtensionKeyName];
                    if (extension) {
                        NSString* identifier = [extension objectForKey:ExtensionIdentify];
                        if ([identifier isEqualToString:AppUpLoaderKey]) {
                            broadCastPicker.preferredExtension = bundle.bundleIdentifier;
                            break;
                        }
                    }
                }
            }
        }
        broadCastPicker.showsMicrophoneButton = false;
        broadCastPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return self;
}

- (void)launch {
    for (UIView* view in _sysBroacastPicker.subviews) {
        UIButton* button = (UIButton*)view;
        [button sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

@end
