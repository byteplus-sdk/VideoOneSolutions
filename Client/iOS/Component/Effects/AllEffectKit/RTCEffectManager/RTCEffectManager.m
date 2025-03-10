//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCEffectManager.h"
#import "BaseRTCManager.h"
#import <ToolKit/ToolKit.h>

@interface RTCEffectManager ()

@property (nonatomic, weak) ByteRTCVideoEffect *videoEffect;
@property (nonatomic, strong) NSArray *effectNodes;
@property (nonatomic, copy) NSString *stickerNode;
@property (nonatomic, copy) NSString *filterNode;
@property (nonatomic, assign) float filterIntensity;

@end

@implementation RTCEffectManager


#pragma MARK - BytedEffectComponentDelegate
- (instancetype)protocol:(BytedEffectProtocol *)protocol
          initWithEngine:(id)engine
                useCache:(BOOL)useCache {
    self.useCache = useCache;
    _videoEffect = [(ByteRTCVideo *)engine getVideoEffectInterface];
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
    int errorCode = [self.videoEffect initCVResource:licPath withAlgoModelDir:modelPath];
    if (errorCode != 0) {
        [self showError:@(errorCode)];
        return  NO;
    }
    int errorCode2 = [self.videoEffect enableVideoEffect];
    if (errorCode2 != 0) {
        [self showError:@(errorCode2)];
        return NO;
    }
    return YES;
}


#pragma MARK -  EffectUIKitUIManagerDelegate
- (void)effectBeautyNode:(NSString *)nodePath nodeKey:(NSString *)nodeKey nodeValue:(float)nodeValue {
    [self.videoEffect updateEffectNode:nodePath key:nodeKey value:nodeValue];
}
- (void)effectBeautyNodesChanged:(NSArray<NSString *> *)nodes tags:(NSArray<NSString *> *)tags {
    self.effectNodes = (nodes ?: @[]).copy;
       if (self.stickerNode.length > 0) {
           [self.videoEffect setEffectNodes:[nodes arrayByAddingObject:self.stickerNode]];
       } else {
           [self.videoEffect setEffectNodes:nodes];
       }
}
- (void)effectFilterPathChanged:(NSString *)filterPath intensity:(CGFloat)intensity {
    self.filterNode = filterPath;
    self.filterIntensity = intensity;
    [self.videoEffect setColorFilter:filterPath];
    [self.videoEffect setColorFilterIntensity:intensity];
}
- (void)effectFilterIntensityChanged:(CGFloat)intensity {
    self.filterIntensity = intensity;
    [self.videoEffect setColorFilterIntensity:intensity];
}
- (void)effectStickerPathChanged:(NSString *)stickerPath {
    if (self.stickerNode.length > 0) {
            [self.videoEffect removeEffectNodes:@[self.stickerNode]];
        }
        [self.videoEffect appendEffectNodes:@[stickerPath]];
        self.stickerNode = stickerPath;
}
- (void)effectOnTouchDownCompare {
    [self.videoEffect setColorFilterIntensity:0];
    [self.videoEffect setEffectNodes:@[]];
}
- (void)effectOnTouchUpCompare {
    [self.effectUIManager recover];
}

@end
