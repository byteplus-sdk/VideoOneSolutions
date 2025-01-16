//
//  MDPlayerContextKeyDefine.m
//  MDPlayerKit
//

#import "MDPlayerContextKeyDefine.h"

#pragma mark - Engine
NSString * const MDPlayerContextKeyBeforePlayAction = @"MDPlayerContextKeyBeforePlay";
NSString * const MDPlayerContextKeyPlayAction = @"MDPlayerContextKeyPlay";
NSString * const MDPlayerContextKeyPauseAction = @"MDPlayerContextKeyPause";
NSString * const MDPlayerContextKeyStopAction = @"MDPlayerContextKeyStopAction";
NSString * const MDPlayerContextKeyPlaybackState = @"MDPlayerContextKeyPlaybackState";
NSString * const MDPlayerContextKeyLoadState = @"MDPlayerContextKeyLoadState";
NSString * const MDPlayerContextKeyEnginePrepared = @"MDPlayerContextKeyEnginePrepared";
NSString * const MDPlayerContextKeyReadyForDisplay = @"MDPlayerContextKeyReadyForDisplay";
NSString * const MDPlayerContextKeyReadyToPlay = @"MDPlayerContextKeyReadyToPlay";
NSString * const MDPlayerContextKeyPlaybackDidFinish = @"MDPlayerContextKeyPlaybackDidFinish";
NSString * const MDPlayerContextKeyVolumeChanged = @"MDPlayerContextKeyVolumeChanged";
NSString * const MDPlayerContextKeyPlaybackSpeedChanged = @"MDPlayerContextKeyPlaybackSpeedChanged";
NSString * const MDPlayerContextKeyResolutionChanged = @"MDPlayerContextKeyResolutionChanged";
NSString * const MDPlayerContextKeyRadioModeChanged = @"MDPlayerContextKeyRadioModeChanged";
NSString * const MDPlayerContextKeyScaleModeChanged = @"MDPlayerContextKeyScaleModeChanged";

#pragma mark - Player control
NSString * const MDPlayerContextKeyControlTemplateChanged = @"MDPlayerContextKeyControlTemplateChanged";
NSString * const MDPlayerContextKeyShowControl = @"MDPlayerContextKeyShowControl";
NSString * const MDPlayerContextKeyLockControl = @"MDPlayerContextKeyLockControl";
NSString * const MDPlayerContextKeyControlViewSingleTap = @"MDPlayerContextKeyControlViewSingleTap";
NSString * const MDPlayerContextKeyPlayButtonSingleTap = @"MDPlayerContextKeyPlayButtonSingleTap";
NSString * const MDPlayerContextKeyPlayButtonDoubleTap = @"MDPlayerContextKeyPlayButtonDoubleTap";

#pragma mark - Player UI
NSString * const MDPlayerContextKeyVideoTitleChanged = @"MDPlayerContextKeyVideoTitleChanged";
NSString * const MDPlayerContextKeyShowPanel = @"MDPlayerContextKeyShowPanel";
NSString * const MDPlayerContextKeySliderMarkPoints = @"MDPlayerContextKeySliderMarkPoints";
NSString * const MDPlayerContextKeySliderCirclePoints = @"MDPlayerContextKeySliderCirclePoints";

#pragma mark - Seek
NSString * const MDPlayerContextKeySliderSeekBegin = @"MDPlayerContextKeySliderSeekBegin";
NSString * const MDPlayerContextKeySliderChanging = @"MDPlayerContextKeySliderChanging";
NSString * const MDPlayerContextKeySliderCancel = @"MDPlayerContextKeySliderCancel";
NSString * const MDPlayerContextKeySliderSeekEnd = @"MDPlayerContextKeySliderSeekEnd";

#pragma mark - Rotate screen
NSString * const MDPlayerContextKeyRotateScreen = @"MDPlayerContextKeyRotateScreen";
NSString * const MDPlayerContextKeySupportsPortaitFullScreen = @"MDPlayerContextKeySupportsPortaitFullScreen";

#pragma mark - Loading
NSString * const MDPlayerContextKeyShowLoadingNetWorkSpeed = @"MDPlayerContextKeyShowLoadingNetWorkSpeed";
NSString * const MDPlayerContextKeyStartLoading = @"MDPlayerContextKeyStartLoading";
NSString * const MDPlayerContextKeyFinishLoading = @"MDPlayerContextKeyFinishLoading";

#pragma mark - Player Speed
NSString * const MDPlayerContextKeySpeedTipViewShowed = @"MDPlayerContextKeySpeedTipViewShowed";

#pragma mark - DataModel
NSString * const MDPlayerContextKeyDataModelChanged = @"MDPlayerContextKeyDataModelChanged";

#pragma mark - MiniDrama
NSString * const MDPlayerContextKeyMiniDramaDataModelChanged = @"MDPlayerContextKeyMiniDramaDataModelChanged";
NSString * const MDPlayerContextKeyMiniDramaShowPayModule = @"MDPlayerContextKeyMiniDramaShowPayModule";

#pragma mark - Toast
NSString * const MDPlayerContextKeyShowToastModule = @"MDPlayerContextKeyShowToastModule";


