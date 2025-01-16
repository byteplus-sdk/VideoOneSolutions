//
//  MDInterfaceBridge.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/15.
//

@protocol MDPlayInfoProtocol <NSObject>

@required
- (NSInteger)currentPlaybackState;
 
- (NSTimeInterval)duration;

- (NSTimeInterval)playableDuration;

- (NSString *)title;
    
- (BOOL)loopPlayOpen;

- (BOOL)srOpen;

- (CGFloat)currentPlaySpeed;

- (NSString *)currentPlaySpeedForDisplay;

- (NSArray *)playSpeedSet;

- (NSInteger)currentResolution;

- (NSArray *)resolutionSet;

- (NSString *)currentResolutionForDisplay;

- (CGFloat)currentVolume;

- (CGFloat)currentBrightness;

- (BOOL)isPipOpen;

- (void)enablePIP:(void (^)(BOOL isOpenPip))block;

- (void)disablePIP;

@end

@interface MDInterfaceBridge : NSObject <MDPlayInfoProtocol>

+ (instancetype)bridge;

+ (void)destroyUnit;

@end
