//
//  LiveDarkFrameProvider.h
//  InteractiveLive
//
//  Created by bytedance on 2023/11/28.
//

#import <Foundation/Foundation.h>

@protocol LiveDarkFrameProviderDelegate <NSObject>

- (void)darkFrameProviderDidOutput:(CVPixelBufferRef)darkframe;

@end


@interface LiveDarkFrameProvider : NSObject

@property (nonatomic, weak) id<LiveDarkFrameProviderDelegate> delegate;

- (void)startPushDarkFrame;

- (void)stopPushDarkFrame;

@end


