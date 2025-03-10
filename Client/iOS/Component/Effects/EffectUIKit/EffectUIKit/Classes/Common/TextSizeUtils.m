// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TextSizeUtils.h"

@implementation TextSizeUtils

+ (CGFloat)calculateTextWidth:(NSString *)str size:(CGFloat)fontSize {
    return [str boundingRectWithSize:CGSizeMake(10000, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size.width;
}

@end
