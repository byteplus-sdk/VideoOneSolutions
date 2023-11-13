// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceProtocol.h"

@class VEVideoModel;

@interface VEInterfaceSimpleBlockSceneConf : NSObject <VEInterfaceElementDataSource>

@property (nonatomic, strong) VEVideoModel *videoModel;

@end
