// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef Constants_h
#define Constants_h

#define ToolKitBundleName @"ToolKit"

#define AvatarBundleName @"Avatar"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define WeakSelf __weak typeof(self) wself = self;

#define StrongSelf __strong __typeof(self) sself = wself;

#define IsEmptyStr(string) (string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@""] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ? YES : NO)

#define NOEmptyStr(string) (string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@""] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0 ? NO : YES)

//#ifndef dispatch_queue_async_safe
//#define dispatch_queue_async_safe(queue, block)                                                      \
//    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) { \
//        block();                                                                                     \
//    } else {                                                                                         \
//        dispatch_async(queue, block);                                                                \
//    }
//#endif
 
NS_INLINE void dispatch_queue_async_safe(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

#define SYSTEM_VERSION_LESS_THAN(v) \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define PrivacyPolicy @"https://docs.byteplus.com/en/legal/docs/privacy-policy"

#define TermsOfService @"https://docs.byteplus.com/byteplus-vos/docs/terms-of-service?version=v1.0"

#endif /* Constants_h */
