//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//
#import "EffectBeautyComponent.h"
//#import "bef_effect_ai_version.h"
#import <ToolKit/ToolKit.h>

static CGFloat const kBeautyViewHeight = 200;
@interface EffectBeautyComponent () <EffectUIKitUIManagerDelegate>
@end
@implementation EffectBeautyComponent

- (void)showError:(id)error {
    [ToastComponent.shareToastComponent showWithMessage:[NSString stringWithFormat:LocalizedStringFromBundle(@"effect_sdk_init_failed_tip", ToolKitBundleName), error]];
}

- (BOOL)initEffectSDK {
    return NO;
}

#pragma MARK - BytedEffectComponentDelegate
- (instancetype)protocol:(BytedEffectProtocol *)protocol
          initWithEngine:(id)engine
                useCache:(BOOL)useCache {
    self.useCache = useCache;
    return (EffectBeautyComponent *) protocol;
}


- (void)protocol:(BytedEffectProtocol *)protocol
    showWithView:(UIView *)superView
    dismissBlock:(void (^)(BOOL result))block {
    [self.effectUIManager setDidHidBlock:^{
        if (block) {
            block(YES);
        }
    }];
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

#pragma MARK -  EffectUIKitUIManagerDelegate
- (void)effectBeautyNode:(NSString *)nodePath nodeKey:(NSString *)nodeKey nodeValue:(float)nodeValue {

}
- (void)effectBeautyNodesChanged:(NSArray<NSString *> *)nodes tags:(NSArray<NSString *> *)tags {

}
- (void)effectFilterPathChanged:(NSString *)filterPath intensity:(CGFloat)intensity {

}
- (void)effectFilterIntensityChanged:(CGFloat)intensity {

}
- (void)effectStickerPathChanged:(NSString *)stickerPath {

}
- (void)effectOnTouchDownCompare {
    
}
- (void)effectOnTouchUpCompare {

}
#pragma MARK - Getter
- (EffectUIManager *)effectUIManager {
    if (!_effectUIManager) {
        _effectUIManager = [[EffectUIManager alloc] initWithIdentifier:@"videoone_effect"];
        _effectUIManager.delegate = self;
        _effectUIManager.showCompare = NO;
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
