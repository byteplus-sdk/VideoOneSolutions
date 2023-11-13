// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol VEPlayCoreAbilityProtocol;
@protocol VEInterfaceElementDataSource;

@protocol VEInterfaceDelegate <NSObject>
@optional
- (void)interfaceCallScreenRotation:(UIView *)interface;

- (void)interfaceCallPageBack:(UIView *)interface;

- (void)interfaceShouldEnableSlide:(BOOL)enable;

@end

@class VEEventMessageBus, VEEventPoster;

@interface VEInterface : UIView

/**
 * This method is the only entry to initialize the VEInterface
 * @param core is the class which implement 'VEPlayCoreAbilityProtocol', described the ability of player you choose.
 * @param scene is a config class which implement 'VEInterfaceElementDataSource' to describes UI's detail you want.
 */
- (instancetype)initWithPlayerCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene;
// If you want change the player core of VEInterface, this method will work.
- (void)reloadCore:(id<VEPlayCoreAbilityProtocol>)core;

@property (nonatomic, weak) id<VEInterfaceDelegate> delegate;

@property (nonatomic, weak, readonly) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong, readonly) VEEventPoster *eventPoster;

- (void)destory;

@end
