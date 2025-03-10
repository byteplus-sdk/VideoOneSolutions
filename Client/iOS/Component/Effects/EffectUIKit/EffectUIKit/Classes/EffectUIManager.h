// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "EffectUIResourceHelper.h"
NS_ASSUME_NONNULL_BEGIN

@protocol EffectUIKitUIManagerDelegate <NSObject>
@optional
/// Update the strength of beauty items
- (void)effectBeautyNode:(NSString *)nodePath nodeKey:(NSString *)nodeKey nodeValue:(float)nodeValue;

/// Updated Nodes for beauty
- (void)effectBeautyNodesChanged:(NSArray <NSString *>*)nodes tags:(NSArray <NSString *>*)tags;

/// Choose a filter, with default intensity
- (void)effectFilterPathChanged:(NSString *)filterPath intensity:(CGFloat)intensity;

/// Modify the current filter strength
- (void)effectFilterIntensityChanged:(CGFloat)intensity;

/// choose sticker
- (void)effectStickerPathChanged:(NSString *)stickerPath;

/// Click the reset button, if it returns YES, the internal will automatically reset, if it returns NO, the internal will not be processed
- (void)effectOnResetClickWithCompletion:(void (^)(BOOL result))completion;

/// Click the compare button
- (void)effectOnTouchDownCompare;

/// Compare button let go
- (void)effectOnTouchUpCompare;

/// The corresponding beauty resource was not found, do you need to download it?
- (BOOL)effectShouldDownloadNode:(NSString *)nodePath;

/// Return the corresponding beauty resources by itself
- (NSString *)effectFallbackPathForNode:(NSString *)nodePath;

/// Download Beauty Resources
/// Need to download to nodePath this path
/// progressBlock and completionBlock are held by themselves, and the corresponding values are passed in
- (void)effectDownloadNode:(NSString *)nodePath progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL success, NSError *error))completionBlock;

/// cancel downloading resource
- (void)effectCancelDownloadNode:(NSString *)nodePath;
@end

@interface EffectUIManager : NSObject

/// Unique identifier, the cache will be loaded according to the current identifier
@property (nonatomic, copy, readonly) NSString *identifier;

/// Whether to use the default recommended beauty parameters, the default is YES
@property (nonatomic, assign) BOOL defaultEffectOn;

/// Whether it can be cached, the default is YES
@property (nonatomic, assign) BOOL cacheable;

/// Whether to display the button of comparing before and after beautification, the default is YES
@property (nonatomic, assign) BOOL showCompare;

/// Whether to display the reset button, the default is YES
@property (nonatomic, assign) BOOL showReset;

/// The distance from the bottom, the default bottom safety distance
@property (nonatomic, assign) CGFloat bottomMargin;

/// slider height, default 45
@property (nonatomic, assign) CGFloat sliderHeight;

/// Tab bar height, default 44
@property (nonatomic, assign) CGFloat topTabHeight;

/// Middle content part height, default 130
@property (nonatomic, assign) CGFloat boardContentHeight;

/// The distance between the slider and the panel, default 8
@property (nonatomic, assign) CGFloat sliderBottomMargin;

/// On which view to display, the default order is targetView -> fromVC.view -> keywindow
@property (nonatomic, weak, nullable) UIView *showTargetView;

/// Panel background color [[UIColor blackColor] colorWithAlphaComponent:0.7]
@property (nonatomic, strong) UIColor *backgroundColor;

/// VisulEffect
@property (nonatomic, assign) BOOL showVisulEffect;

/// rounded corners
@property (nonatomic, assign) CGFloat cornerRadius;

/// Is it showing
@property (nonatomic, assign, getter=isShowing, readonly) BOOL showing;

/// hide callback
@property(nonatomic, copy) void (^didHidBlock)(void);

/// configure proxy
@property (nonatomic, weak, nullable) id <EffectUIKitUIManagerDelegate> delegate;

/// resource retrieval
@property (nonatomic, strong, readonly) EffectUIResourceHelper *resourceHelper;

/// initialization
/// - Parameter identifier: Unique identifier for cache access
- (instancetype)initWithIdentifier:(NSString *)identifier;

/// initialization
/// - Parameters:
///   - identifier: Unique identifier for cache access
///   - fromVC:Which controller to display on, the default is the top controller
- (instancetype)initWithIdentifier:(NSString *)identifier fromVC:(UIViewController *)fromVC;

/// display UI
- (void)show;

/// hide UI
- (void)hide;

/// Reset beauty effects
- (void)reset;

/// Restore the last beauty effect. If you have selected it before, you will use the local cache. If you have not selected &&defaultEffectOn == YES, you will use the default beauty effect
- (void)recover;

/// refresh view
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
