//
//  MDSliderControlView.h
//  MDPlayerUIModule
//

#import "MDVideoPlayback.h"

typedef NS_ENUM(NSInteger, MDSliderControlViewContentMode) {
    MDSliderControlViewContentModeCenter = 0,
    MDSliderControlViewContentModeTop,
    MDSliderControlViewContentModeBottom
};

@class MDSliderControlView;

@protocol MDSliderControlViewDelegate <NSObject>

- (void)progressBeginSlideChange:(MDSliderControlView *)sliderControlView;

- (void)progressSliding:(MDSliderControlView *)sliderControlView value:(CGFloat)value;

- (void)progressDidEndSlide:(MDSliderControlView *)sliderControlView value:(CGFloat)value;

- (void)progressSlideCancel:(MDSliderControlView *)sliderControlView;

@end

@interface MDSliderControlView : UIView

@property (nonatomic, weak) id<MDSliderControlViewDelegate> delegate;

- (instancetype)initWithContentMode:(MDSliderControlViewContentMode)contentMode;

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat bufferValue;

@property (nonatomic, assign) CGFloat sliderCoefficient; // Default 3，[1-10]
@property (nonatomic, assign) MDSliderControlViewContentMode contentMode;

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *progressBufferColor;
@property (nonatomic, strong) UIColor *progressBackgroundColor;

@property (nonatomic, assign) NSInteger thumbOffset;
@property (nonatomic, assign) NSInteger thumbHeight;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *thumbTouchImage;

@property (nonatomic, assign) CGSize extendTouchSize;

@end
