// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELDeviceHelper.h"
#import "UIImage+VELAdd.h"
#import "UIColor+VELAdd.h"
#import "VELLogger.h"
#define VEL_NAVIGATION_HEIGHT [VELDeviceHelper navigationBarHeight]
#define VEL_STATUS_BAR_HEIGHT [VELDeviceHelper statusBarHeight]
#define VELColorWithHexString(hex) [UIColor vel_colorWithHexString:hex]
#define VELColorWithHex(hex) VELColorWithHexString(@#hex)
#define VELViewBackgroundColor VELColorWithHex(0xf7f7f7)
#define VEL_IS_INTERFACE_LANDSCAPE UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)
#define VEL_IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])
#define VEL_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define VEL_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define VEL_DEVICE_WIDTH MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#define VEL_DEVICE_HEIGHT MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#define VEL_SCREEN_SIZE ([[UIScreen mainScreen] bounds].size)
#define VEL_SCREEN_SCALE ([[UIScreen mainScreen] scale])
#define VELUIImageMake(img) [UIImage vel_imageNamed:img]
#define VEL_IS_NULL_OBJ(obj) (obj == nil || ((id)obj == NSNull.null) || [obj isKindOfClass:NSNull.class])
#define VEL_IS_EMPTY_STRING(s) (VEL_IS_NULL_OBJ(s) || s.length == 0)
#define VEL_IS_NOT_EMPTY_STRING(s) !VEL_IS_EMPTY_STRING(s)
#define VEL_SAFE_INSERT [VELDeviceHelper safeAreaInsets]
#define VEL_ERROR(c, des) [NSError errorWithDomain:NSURLErrorDomain code:c userInfo:@{NSLocalizedDescriptionKey : des?:@""}]
#define VEL_CMTIME_IS_VALID(time) (CMTIME_IS_NUMERIC(time) && CMTimeGetSeconds(time) > 0 && time.value > 0 && time.timescale > 1)
#define VEL_CURRENT_CMTIME CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000)
#define VEL_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define VEL_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define VEL_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define VEL_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define VEL_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#ifndef vel_keywordify
#   if DEBUG
#       define vel_keywordify autoreleasepool {}
#   else
#       define vel_keywordify try {} @catch (...) {}
#   endif
#endif

#ifndef weakify
    #if __has_feature(objc_arc)
        #define weakify(object) vel_keywordify __weak __typeof__(object) weak##_##object = object;
    #else
        #define weakify(object) vel_keywordify __block __typeof__(object) block##_##object = object;
    #endif
#endif

#ifndef strongify
    #if __has_feature(objc_arc)
        #define strongify(object) vel_keywordify __typeof__(object) object = weak##_##object;
    #else
        #define strongify(object) vel_keywordify __typeof__(object) object = block##_##object;
    #endif
#endif

CG_INLINE CGFloat VELCGFloatRemoveMin(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}

CG_INLINE CGFloat VELCGFloatFlatted(CGFloat floatValue) {
    return ceil(VELCGFloatRemoveMin(floatValue) * VEL_SCREEN_SCALE) / VEL_SCREEN_SCALE;
}

CG_INLINE CGSize VELCGSizeFlatted(CGSize size) {
    return CGSizeMake(VELCGFloatFlatted(size.width), VELCGFloatFlatted(size.height));
}

CG_INLINE CGFloat VELCGFloatGetCenter(CGFloat parent, CGFloat child) {
    return VELCGFloatFlatted((parent - child) / 2.0);
}

CG_INLINE CGFloat VELUIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

CG_INLINE CGFloat VELUIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

CG_INLINE UIEdgeInsets VELUIEdgeInsetsSetRight(UIEdgeInsets insets, CGFloat right) {
    insets.right = VELCGFloatFlatted(right);
    return insets;
}
CG_INLINE UIEdgeInsets VELUIEdgeInsetsConcat(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    insets1.top += insets2.top;
    insets1.left += insets2.left;
    insets1.bottom += insets2.bottom;
    insets1.right += insets2.right;
    return insets1;
}

CG_INLINE UIEdgeInsets VELUIEdgeInsetsRemoveFloatMin(UIEdgeInsets insets) {
    return UIEdgeInsetsMake(VELCGFloatRemoveMin(insets.top),
                            VELCGFloatRemoveMin(insets.left),
                            VELCGFloatRemoveMin(insets.bottom),
                            VELCGFloatRemoveMin(insets.right));
}

CG_INLINE BOOL VELCGRectIsNaN(CGRect rect) {
    return isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height);
}

CG_INLINE BOOL VELCGRectIsInf(CGRect rect) {
    return isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height);
}

CG_INLINE BOOL VELCGRectIsValidated(CGRect rect) {
    return !CGRectIsNull(rect) && !CGRectIsInfinite(rect) && !VELCGRectIsNaN(rect) && !VELCGRectIsInf(rect);
}

CG_INLINE CGRect VELCGRectFlatted(CGRect rect) {
    return CGRectMake(VELCGFloatFlatted(rect.origin.x),
                      VELCGFloatFlatted(rect.origin.y),
                      VELCGFloatFlatted(rect.size.width),
                      VELCGFloatFlatted(rect.size.height));
}

CG_INLINE CGRect VELCGRectMakeWithSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

CG_INLINE CGRect VELCGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = VELCGFloatFlatted(x);
    return rect;
}

CG_INLINE CGRect VELCGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = VELCGFloatFlatted(y);
    return rect;
}

CG_INLINE CGRect VELCGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
    rect.origin.x = VELCGFloatFlatted(x);
    rect.origin.y = VELCGFloatFlatted(y);
    return rect;
}

CG_INLINE CGRect VELCGRectSetWidth(CGRect rect, CGFloat width) {
    if (width < 0) {
        return rect;
    }
    rect.size.width = VELCGFloatFlatted(width);
    return rect;
}

CG_INLINE CGRect VELCGRectSetHeight(CGRect rect, CGFloat height) {
    if (height < 0) {
        return rect;
    }
    rect.size.height = VELCGFloatFlatted(height);
    return rect;
}

CG_INLINE CGRect VELCGRectSetSize(CGRect rect, CGSize size) {
    rect.size = VELCGSizeFlatted(size);
    return rect;
}

CG_INLINE CGRect VELCGRectFlatMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(VELCGFloatFlatted(x), VELCGFloatFlatted(y), VELCGFloatFlatted(width), VELCGFloatFlatted(height));
}

CG_INLINE CGPoint VELCGPointGetCenterWithRect(CGRect rect) {
    return CGPointMake(VELCGFloatFlatted(CGRectGetMidX(rect)), VELCGFloatFlatted(CGRectGetMidY(rect)));
}

UIKIT_STATIC_INLINE void vel_sync_main_queue(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

UIKIT_STATIC_INLINE void vel_async_main_queue(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#define VELLog(atag, alevel, fmt, ...) \
[VELLogger log:NO \
              tag:atag \
            level:alevel \
             file:__FILE_NAME__ \
         function:__PRETTY_FUNCTION__ \
             line:__LINE__ \
           format:(fmt), ##__VA_ARGS__]
#define VELLogVerbose(tag, fmt, ...)        VELLog(tag, VELLogLevelVerbose, fmt,  ##__VA_ARGS__)
#define VELLogDebug(tag, fmt, ...)          VELLog(tag, VELLogLevelDebug, fmt,  ##__VA_ARGS__)
#define VELLogInfo(tag, fmt, ...)           VELLog(tag, VELLogLevelInfo, fmt,  ##__VA_ARGS__)
#define VELLogWarn(tag, fmt, ...)           VELLog(tag, VELLogLevelWarning, fmt,  ##__VA_ARGS__)
#define VELLogError(tag, fmt, ...)          VELLog(tag, VELLogLevelError, fmt,  ##__VA_ARGS__)
