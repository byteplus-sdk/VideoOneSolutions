//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceBaseElementConf.h"
#import "VEInterfaceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const VEBackButtonIdentifier;

extern NSString *const VEResolutionButtonIdentifier;

extern NSString *const VEPlaySpeedButtonIdentifier;

extern NSString *const VEMoreButtonIdentifier;

extern NSString *const VELockButtonIdentifier;

extern NSString *const VETitleLabelIdentifier;

extern NSString *const VELoopPlayButtonIdentifier;

extern NSString *const VEVolumeGestureIdentifier;

extern NSString *const VEBrightnessGestureIdentifier;

extern NSString *const VEPlayGestureIdentifier;

extern NSString *const VEMenuButtonCellIdentifier;

extern NSString *const VEMaskViewIdentifier;

extern NSString *const VESocialStackViewIdentifier;

extern NSString *const VELeftBrightnessSliderIdentifier;

extern NSString *const VERightVolumeSliderIdentifier;

extern NSString *const VEPIPButtonIdentifier;

@class VEVideoModel;

@interface VEInterfaceBaseVideoDetailSceneConf : VEInterfaceBaseElementConf <VEInterfaceElementDataSource>

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, assign) BOOL skipPlayMode;

@property (nonatomic, assign) BOOL skipPIPMode;

@property (nonatomic, strong) NSArray<id<VEInterfaceElementDescription>> *customizedElements;

- (VEInterfaceElementDescriptionImp *)resolutionButton;

- (nullable NSArray *)extraElements;

@end

NS_ASSUME_NONNULL_END
