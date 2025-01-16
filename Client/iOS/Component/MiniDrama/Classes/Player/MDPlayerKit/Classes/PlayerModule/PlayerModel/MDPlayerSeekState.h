//
//  MDPlayerSeekState.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MDPlayerSeekStage) {
    MDPlayerSeekStageNone = 0,
    MDPlayerSeekStageSliderBegin,
    MDPlayerSeekStageSliderChanging,
    MDPlayerSeekStageSliderEnd,
    MDPlayerSeekStageSliderCancel
};

@interface MDPlayerSeekState : NSObject

@property (nonatomic, assign) MDPlayerSeekStage seekStage;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
