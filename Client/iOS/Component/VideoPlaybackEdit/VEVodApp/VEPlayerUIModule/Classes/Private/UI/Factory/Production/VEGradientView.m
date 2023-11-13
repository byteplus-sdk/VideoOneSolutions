// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEGradientView.h"

@implementation VEGradientView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

@end
