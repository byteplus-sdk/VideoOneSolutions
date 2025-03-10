//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//
#import <ToolKit/BaseRTCManager.h>
#import "EffectBeautyComponent.h"
#import "bef_effect_ai_version.h"
#import <TTSDK/VeLivePusher.h>
#import <EffectUIKit/EffectUIKit.h>
#import <ToolKit/ToolKit.h>

static CGFloat const kBeautyViewHeight = 200;
@interface EffectBeautyComponent () <EffectUIKitUIManagerDelegate>
@property (nonatomic, strong) EffectUIManager *effectUIManager;
@property (nonatomic, strong) EffectUIResourceHelper *resourceHelper;
@property (nonatomic, weak) id videoEffect;
@property (nonatomic, assign) EffectType effectType;
@property (nonatomic, strong) NSArray *effectNodes;
@property (nonatomic, copy) NSString *stickerNode;
@property (nonatomic, copy) NSString *filterNode;
@property (nonatomic, assign) float filterIntensity;
@property (nonatomic, assign) BOOL useCache;
@end
@implementation EffectBeautyComponent

- (instancetype)protocol:(BytedEffectProtocol *)protocol
          initWithEngine:(id)engine
                useCache:(BOOL)useCache {
    if ([engine isKindOfClass:ByteRTCVideo.class] && [engine respondsToSelector:@selector(getVideoEffectInterface)]) {
        self.effectType = EffectTypeRTC;
        self.videoEffect = [engine getVideoEffectInterface];
    } else if ([engine isKindOfClass:VeLivePusher.class] && [engine respondsToSelector:@selector(getVideoEffectManager)]) {
        self.effectType = EffectTypeMediaLive;
        self.videoEffect = [engine getVideoEffectManager];
    } else {
        self.effectType = EffectTypeUnknown;
        [self showError];
        return nil;
    }
    self.useCache = useCache;
    if ([self initEffectSDK]) {
        return (EffectBeautyComponent *)protocol;
    } else {
        [self showError];
        return nil;
    }
}
- (void)showError {
    char version[1024];
    bef_effect_ai_get_version(version, 1024);
    NSLog(@"effect version = %s", version);
    [ToastComponent.shareToastComponent showWithMessage:[NSString stringWithFormat:LocalizedStringFromBundle(@"effect_sdk_init_failed_tip", ToolKitBundleName), version]];
}

- (BOOL)initEffectSDK {
    NSString *licPath = [self.resourceHelper findLicenseInMainBundleLicenseName:nil];
    NSString *modelPath = self.resourceHelper.modelPath;
    if (licPath.length <= 0) {
        return NO;
    }
    
    [self initCVResource:licPath withAlgoModelDir:modelPath];
    int errorCode = [self enableVideoEffect];
    if (errorCode != 0) {
        return NO;
    }
    return YES;
}

#pragma Mark - videoEffect Method

- (int) initCVResource:(NSString* _Nonnull)license_file
      withAlgoModelDir: (NSString* _Nonnull)algo_model_dir {
    if (self.effectType == EffectTypeRTC) {
        return [(ByteRTCVideoEffect *)self.videoEffect initCVResource:license_file withAlgoModelDir:algo_model_dir];
    } else if (self.effectType == EffectTypeMediaLive) {
        int errorCode1 = [(VeLiveVideoEffectManager *)self.videoEffect setAlgoModelPath:algo_model_dir];
        VeLiveVideoEffectLicenseConfiguration *licenseConfig = [[VeLiveVideoEffectLicenseConfiguration alloc] initWithPath:license_file];
        int errorCode2 = [(VeLiveVideoEffectManager *)self.videoEffect setupWithConfig:licenseConfig];
        if (errorCode1 == 0 && errorCode2 == 0) {
            return 0;
        } else {
            return -1;
        }
    } else {
        return -1;
    }
}

- (int)enableVideoEffect {
    if (self.effectType == EffectTypeRTC) {
        return [(ByteRTCVideoEffect *)self.videoEffect enableVideoEffect];
    } else if (self.effectType == EffectTypeMediaLive) {
        return [(VeLiveVideoEffectManager *)self.videoEffect setEnable:YES];
    } else {
        return -1;
    }
}

- (void)setEffectNodes:(NSArray<NSString*>*_Nonnull)effect_nodes; {
    if (self.effectType == EffectTypeRTC) {
        [(ByteRTCVideoEffect *)self.videoEffect setEffectNodes:effect_nodes];
    } else if (self.effectType == EffectTypeMediaLive) {
        [(VeLiveVideoEffectManager *)self.videoEffect setComposeNodes:effect_nodes];
    }
}

- (void)updateEffectNode:(NSString* _Nonnull)node
                     key:(NSString* _Nonnull)key value:(float) value {
    if (self.effectType == EffectTypeRTC) {
        [(ByteRTCVideoEffect *)self.videoEffect updateEffectNode:node key:key value:value];
    } else if (self.effectType == EffectTypeMediaLive) {
        [(VeLiveVideoEffectManager *)self.videoEffect updateComposerNodeIntensity:node nodeKey:key intensity:value];
    }
}

- (void)setColorFilter:(NSString* _Nonnull)filter_res {
    if (self.effectType == EffectTypeRTC) {
        [(ByteRTCVideoEffect *)self.videoEffect setColorFilter:filter_res];
    } else if (self.effectType == EffectTypeMediaLive) {
        [(VeLiveVideoEffectManager *)self.videoEffect setFilter:filter_res];
    }
}

- (void)setColorFilterIntensity:(float) intensity {
    if (self.effectType == EffectTypeRTC) {
        [(ByteRTCVideoEffect *)self.videoEffect setColorFilterIntensity:intensity];
    } else if (self.effectType == EffectTypeMediaLive) {
        [(VeLiveVideoEffectManager *)self.videoEffect updateFilterIntensity:intensity];
    }
}

- (void)setSticker:(NSString *)stickerNode {
    if (self.effectType == EffectTypeRTC) {
        if (self.stickerNode.length > 0) {
            [(ByteRTCVideoEffect *)self.videoEffect removeEffectNodes:@[self.stickerNode]];
        }
        [(ByteRTCVideoEffect *)self.videoEffect appendEffectNodes:@[stickerNode]];
        self.stickerNode = stickerNode;
    } else if (self.effectType == EffectTypeMediaLive) {
        [(VeLiveVideoEffectManager *)self.videoEffect setSticker:stickerNode];
    }
}

- (void)protocol:(BytedEffectProtocol *)protocol
    showWithView:(UIView *)superView
    dismissBlock:(void (^)(BOOL result))block {
    [self.effectUIManager setDidHidBlock:^{
        if (block) {
            block(YES);
        }
    }];
    // 如果显示的父视图不一致，重建 Manager
    if (self.effectUIManager.showTargetView != superView) {
        _effectUIManager = nil;
    }
    self.effectUIManager.showTargetView = superView;
    [self.effectUIManager show];
}

- (void)protocol:(nonnull BytedEffectProtocol *)protocol reset:(BOOL)result {
    [self.effectUIManager reset];
}

- (void)protocol:(nonnull BytedEffectProtocol *)protocol resume:(BOOL)result {
    [self.effectUIManager recover];
}

// MARK: - EffectUIKitUIManagerDelegate
- (void)effectBeautyNode:(NSString *)nodePath nodeKey:(NSString *)nodeKey nodeValue:(float)nodeValue {
    [self updateEffectNode:nodePath key:nodeKey value:nodeValue];
}
- (void)effectBeautyNodesChanged:(NSArray<NSString *> *)nodes tags:(NSArray<NSString *> *)tags {
    self.effectNodes = (nodes ?: @[]).copy;
    if (self.effectType == EffectTypeRTC) {
        if (self.stickerNode.length > 0) {
            [self setEffectNodes:[nodes arrayByAddingObject:self.stickerNode]];
        } else {
            [self setEffectNodes:nodes];
        }
    } else if (self.effectType == EffectTypeMediaLive) {
        [self setEffectNodes:nodes];
    }
}
- (void)effectFilterPathChanged:(NSString *)filterPath intensity:(CGFloat)intensity {
    self.filterNode = filterPath;
    self.filterIntensity = intensity;
    [self setColorFilter:filterPath];
    [self setColorFilterIntensity:intensity];
}
- (void)effectFilterIntensityChanged:(CGFloat)intensity {
    self.filterIntensity = intensity;
    [self setColorFilterIntensity:intensity];
}
- (void)effectStickerPathChanged:(NSString *)stickerPath {
    [self setSticker:stickerPath];
}
- (void)effectOnTouchDownCompare {
    if (self.effectType == EffectTypeRTC) {
        [(ByteRTCVideoEffect *)self.videoEffect setColorFilterIntensity:0];
        [(ByteRTCVideoEffect *)self.videoEffect setEffectNodes:@[]];
    }
}
- (void)effectOnTouchUpCompare {
    if (self.effectType == EffectTypeRTC) {
        [self.effectUIManager recover];
    }
}

- (EffectUIManager *)effectUIManager {
    if (!_effectUIManager) {
        _effectUIManager = [[EffectUIManager alloc] initWithIdentifier:@"interact_effect"];
        _effectUIManager.delegate = self;
        _effectUIManager.showCompare = NO;
        _effectUIManager.showVisulEffect = YES;
        _effectUIManager.showReset = NO;
        _effectUIManager.cacheable = self.useCache;
        _effectUIManager.boardContentHeight = kBeautyViewHeight;
        _effectUIManager.backgroundColor = [UIColor blackColor];
    }
    return _effectUIManager;
}

- (EffectUIResourceHelper *)resourceHelper {
    return self.effectUIManager.resourceHelper;
}
@end
