//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "STSToken.h"
#import <ToolKit/NetworkingManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (Uploader)

+ (void)getUploadToken:(void (^__nullable)(STSToken *_Nullable token,
                                           NetworkingResponse *response))block;

@end

NS_ASSUME_NONNULL_END
