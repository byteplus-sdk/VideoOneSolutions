//
//  MDPlayerContextKeyDefine.h
//  MDPlayerKit
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Engine
extern NSString * const MDPlayerContextKeyBeforePlayAction;
extern NSString * const MDPlayerContextKeyPlayAction;
extern NSString * const MDPlayerContextKeyPauseAction;
extern NSString * const MDPlayerContextKeyStopAction;
extern NSString * const MDPlayerContextKeyPlaybackState;
extern NSString * const MDPlayerContextKeyLoadState;
extern NSString * const MDPlayerContextKeyEnginePrepared;
extern NSString * const MDPlayerContextKeyReadyForDisplay;
extern NSString * const MDPlayerContextKeyReadyToPlay;
extern NSString * const MDPlayerContextKeyPlaybackDidFinish;
extern NSString * const MDPlayerContextKeyVolumeChanged;
extern NSString * const MDPlayerContextKeyPlaybackSpeedChanged; // TODO
extern NSString * const MDPlayerContextKeyResolutionChanged; // TODO
extern NSString * const MDPlayerContextKeyRadioModeChanged; // TODO
extern NSString * const MDPlayerContextKeyScaleModeChanged; // TODO


#pragma mark - Player control
extern NSString * const MDPlayerContextKeyControlTemplateChanged;
extern NSString * const MDPlayerContextKeyShowControl;
extern NSString * const MDPlayerContextKeyLockControl;
extern NSString * const MDPlayerContextKeyControlViewSingleTap;
extern NSString * const MDPlayerContextKeyPlayButtonSingleTap;
extern NSString * const MDPlayerContextKeyPlayButtonDoubleTap;

#pragma mark - Player UI
extern NSString * const MDPlayerContextKeyVideoTitleChanged;
extern NSString * const MDPlayerContextKeyShowPanel;
extern NSString * const MDPlayerContextKeySliderMarkPoints;
extern NSString * const MDPlayerContextKeySliderCirclePoints;

#pragma mark - Seek
extern NSString * const MDPlayerContextKeySliderSeekBegin;
extern NSString * const MDPlayerContextKeySliderChanging;
extern NSString * const MDPlayerContextKeySliderCancel;
extern NSString * const MDPlayerContextKeySliderSeekEnd;

#pragma mark - Rotate screen
extern NSString * const MDPlayerContextKeyRotateScreen;
extern NSString * const MDPlayerContextKeySupportsPortaitFullScreen;

#pragma mark - Loading
extern NSString * const MDPlayerContextKeyShowLoadingNetWorkSpeed;
extern NSString * const MDPlayerContextKeyStartLoading;
extern NSString * const MDPlayerContextKeyFinishLoading;

#pragma mark - Player Speed
extern NSString * const MDPlayerContextKeySpeedTipViewShowed;

#pragma mark - DataModel
extern NSString * const MDPlayerContextKeyDataModelChanged;

#pragma mark - MiniDrama
extern NSString * const MDPlayerContextKeyMiniDramaDataModelChanged;
extern NSString * const MDPlayerContextKeyMiniDramaShowPayModule;

#pragma mark - Toast
extern NSString * const MDPlayerContextKeyShowToastModule;

NS_ASSUME_NONNULL_END

