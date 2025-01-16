//
//  MDInterface.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/18.
//

/**
 * This Class gives you a uncomplicated way to build a play control view.
 * To achieve this goal，you should provide a instance which implement protocol 'MDPlayCoreAbilityProtocol' and 'MDInterfaceElementDataSource'.
 * The protocol 'MDPlayCoreAbilityProtocol' describes the play ability of the player you choose.
 * The protocol 'MDInterfaceElementDataSource' describes the play control UI's detail you want.
 * However, this is a universal tool, so we have to ask for the screen rotation and page back method of your global logic by the protocol 'MDInterfaceDelegate'.
 */
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
