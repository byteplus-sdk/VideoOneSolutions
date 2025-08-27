//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//
#import "LiveEffectManager.h"
#import <ToolKit/ToolKit.h>
#import <TTSDKFramework/TTSDKFramework.h>

@interface LiveEffectManager ()
@property (nonatomic, weak) VeLiveVideoEffectManager *videoEffect;
@end

@implementation LiveEffectManager

#pragma MARK - BytedEffectComponentDelegate
- (instancetype)protocol:(BytedEffectProtocol *)protocol
          initWithEngine:(id)engine
                useCache:(BOOL)useCache {
    self.useCache = useCache;
    _videoEffect = [(VeLivePusher *)engine getVideoEffectManager];
    if (_videoEffect) {
        if ([self initEffectSDK]) {
            return (EffectBeautyComponent *)protocol;
        } else {
            return nil;
        }
    } else {
        [ToastComponent.shareToastComponent showWithMessage:@"unknown effecType"];
        return nil;
    }
}

- (BOOL)initEffectSDK {
    NSString *licPath = [self.resourceHelper findLicenseInMainBundleLicenseName:nil];
    NSString *modelPath = self.resourceHelper.modelPath;
    if (licPath.length <= 0) {
        [self showError:@"license not found"];
        return NO;
    }
    if (modelPath.length <= 0) {
        [self showError:@"model resource not found"];
        return NO;
    }
    int errorCode1 = [(VeLiveVideoEffectManager *)self.videoEffect setAlgoModelPath:modelPath];
    if (errorCode1 != 0) { 
        [self showError:@(errorCode1)];
        return NO;
    }
    
    VeLiveVideoEffectLicenseConfiguration *licenseConfig = [[VeLiveVideoEffectLicenseConfiguration alloc] initWithPath:licPath];
    int errorCode2 = [(VeLiveVideoEffectManager *)self.videoEffect setupWithConfig:licenseConfig];
    if (errorCode2 != 0) {
        [self showError:@(errorCode2)];
        return NO;
    }
    int errorCode3 = [(VeLiveVideoEffectManager *)self.videoEffect setEnable:YES];
    if (errorCode3 != 0) {
        [self showError:@(errorCode3)];
        return NO;
    }
    return YES ;
}

#pragma MARK -  EffectUIKitUIManagerDelegate
- (void)effectBeautyNode:(NSString *)nodePath nodeKey:(NSString *)nodeKey nodeValue:(float)nodeValue {
    [self.videoEffect updateComposerNodeIntensity:nodePath nodeKey:nodeKey intensity:nodeValue];
}
- (void)effectBeautyNodesChanged:(NSArray<NSString *> *)nodes tags:(NSArray<NSString *> *)tags {
    [self.videoEffect  setComposeNodes:nodes];
}
- (void)effectFilterPathChanged:(NSString *)filterPath intensity:(CGFloat)intensity {
    [self.videoEffect setFilter:filterPath];
    [self.videoEffect updateFilterIntensity:intensity];
}
- (void)effectFilterIntensityChanged:(CGFloat)intensity {
    [self.videoEffect updateFilterIntensity:intensity];
}
- (void)effectStickerPathChanged:(NSString *)stickerPath {
    [self.videoEffect setSticker:stickerPath];
}
- (void)effectOnTouchDownCompare {
    
}
- (void)effectOnTouchUpCompare {

}

- (EffectUIManager *)effectUIManager {
    if (!_effectUIManager) {
        _effectUIManager = [super effectUIManager];
        _effectUIManager.showVisulEffect = YES;
    }
    return _effectUIManager;
}

@end
