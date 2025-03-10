// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDPlayCoreAbilityProtocol;
@protocol MDInterfaceElementDataSource;

@protocol MDInterfaceDelegate <NSObject>

- (void)interfaceCallScreenRotation:(UIView *)interface;

- (void)interfaceCallStartPip:(UIView *)interface;

- (void)interfaceCallPageBack:(UIView *)interface;

- (void)interfaceShouldEnableSlide:(BOOL)enable;

@end

@interface MDInterface : UIView

/**
 * This method is the only entry to initialize the MDInterface
 * @param core is the class which implement 'MDPlayCoreAbilityProtocol', described the ability of player you choose.
 * @param scene is a config class which implement 'MDInterfaceElementDataSource' to describes UI's detail you want.
 */
- (instancetype)initWithPlayerCore:(id<MDPlayCoreAbilityProtocol>)core scene:(id<MDInterfaceElementDataSource>)scene;
// If you want change the player core of MDInterface, this method will work.
- (void)reloadCore:(id<MDPlayCoreAbilityProtocol>)core;

@property (nonatomic, weak) id<MDInterfaceDelegate> delegate;

- (void)destory;

@end
