// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import <AVFoundation/AVFoundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <math.h>

typedef NS_ENUM(NSInteger, AirPlaySessionState) {
  AirPlaySessionStateIdle,
  AirPlaySessionStateRouteSelecting,
  AirPlaySessionStateRouteSelected,
  AirPlaySessionStateStarting,
  AirPlaySessionStateCasting,
  AirPlaySessionStateStopping,
  AirPlaySessionStateFailed,
};

static void *AirPlayExternalPlaybackContext = &AirPlayExternalPlaybackContext;
static void *AirPlayItemStatusContext = &AirPlayItemStatusContext;

@interface AirPlayRelay : RCTEventEmitter <RCTBridgeModule>
@property(nonatomic, assign) AirPlaySessionState state;
@property(nonatomic, assign) NSUInteger generation;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) id progressObserver;
@property(nonatomic, strong) AVPlayer *progressObserverPlayer;
@property(nonatomic, strong) AVPlayer *observedPlayer;
@property(nonatomic, strong) AVPlayerItem *observedItem;
@property(nonatomic, assign) NSUInteger observedGeneration;
@property(nonatomic, strong) NSTimer *startupTimer;
@property(nonatomic, strong) NSTimer *routeSettlementTimer;
@property(nonatomic, copy) NSString *routeUIDAtSelectionBegin;
@property(nonatomic, strong) NSDictionary *configuredMedia;
@property(nonatomic, assign) BOOL routeSelectionArmed;
@property(nonatomic, assign) BOOL stopRelayWhenRouteBecomesLocal;
@property(nonatomic, assign) BOOL hasListeners;
@property(nonatomic, assign) BOOL seekCompleted;
@property(nonatomic, assign) BOOL shouldResumeLocal;
@property(nonatomic, assign) NSTimeInterval lastKnownTime;
@property(nonatomic, assign) BOOL localWasPlaying;
@property(nonatomic, copy) NSString *errorCode;
@property(nonatomic, copy) NSString *errorMessage;
@property(nonatomic, copy) RCTPromiseResolveBlock pendingCompatibilityStartResolve;
@property(nonatomic, copy) RCTPromiseRejectBlock pendingCompatibilityStartReject;
@property(nonatomic, assign) NSUInteger pendingCompatibilityStartGeneration;
@end

@implementation AirPlayRelay

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (instancetype)init
{
  if (self = [super init]) {
    _state = AirPlaySessionStateIdle;
    _generation = 0;
    _lastKnownTime = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if ([NSThread isMainThread]) {
    [self cleanupRelay];
    [self clearPendingCompatibilityStart];
  } else {
    __unsafe_unretained AirPlayRelay *relay = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
      [relay cleanupRelay];
      [relay clearPendingCompatibilityStart];
    });
  }
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"AirPlayRelayStateChanged", @"AirPlayRelayProgress"];
}

- (void)startObserving
{
  self.hasListeners = YES;
  [self emitStateSnapshot];
}

- (void)stopObserving
{
  self.hasListeners = NO;
}

#pragma mark - New state-machine bridge API

RCT_EXPORT_METHOD(configureMedia:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error = nil;
    if (![self storeConfiguredMedia:options error:&error]) {
      reject(@"airplay_relay_invalid_url", error.localizedDescription, error);
      return;
    }

    if (self.state == AirPlaySessionStateRouteSelected &&
        self.routeSelectionArmed && [self isAirPlayRouteActive]) {
      [self startConfiguredRelay];
    }
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(beginRouteSelection:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.stopRelayWhenRouteBecomesLocal = NO;
    NSError *error = nil;
    if (![self beginRouteSelectionOperation:&error]) {
      reject(@"airplay_relay_session_error", @"Failed to configure AirPlay audio session", error);
      return;
    }
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(beginStopRouteSelection:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.stopRelayWhenRouteBecomesLocal = YES;
    NSError *error = nil;
    if (![self beginRouteSelectionOperation:&error]) {
      self.stopRelayWhenRouteBecomesLocal = NO;
      reject(@"airplay_relay_session_error", @"Failed to configure AirPlay stop routes", error);
      return;
    }
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(endRouteSelection:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self finishRouteSelection];
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(getState:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(restoreLocalAudioSession:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error = nil;
    if (![self restoreLocalPlaybackSession:&error]) {
      NSString *message = [self messageByAppendingRestoreError:error
                                                     toMessage:@"Failed to restore local audio session"
                                                       context:@"explicit restore"];
      reject(@"airplay_relay_session_error", message, error);
      return;
    }
    resolve([self stateSnapshot]);
  });
}

#pragma mark - Compatibility bridge API

RCT_EXPORT_METHOD(prepareRouteDetection:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    self.stopRelayWhenRouteBecomesLocal = NO;
    NSError *error = nil;
    if (![self beginRouteSelectionOperation:&error]) {
      reject(@"airplay_relay_session_error", @"Failed to configure AirPlay audio session", error);
      return;
    }
    resolve([self stateSnapshot]);
  });
}

RCT_EXPORT_METHOD(refreshRouteState:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self finishRouteSelection];
    resolve([self compatibilityRouteSnapshot]);
  });
}

RCT_EXPORT_METHOD(getRouteState:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    resolve([self compatibilityRouteSnapshot]);
  });
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self rejectPendingCompatibilityStartWithCode:@"superseded"
                                          message:@"A newer AirPlay relay start superseded this request"
                                       generation:self.pendingCompatibilityStartGeneration];
    NSError *error = nil;
    if (![self storeConfiguredMedia:options error:&error]) {
      reject(@"airplay_relay_invalid_url", error.localizedDescription, error);
      return;
    }
    if (![self isAirPlayRouteActive]) {
      reject(@"airplay_relay_route_inactive",
             @"Cannot start the AirPlay relay without an active AirPlay route",
             nil);
      return;
    }
    self.routeSelectionArmed = YES;
    [self transitionToState:AirPlaySessionStateRouteSelected
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    self.pendingCompatibilityStartResolve = resolve;
    self.pendingCompatibilityStartReject = reject;
    self.pendingCompatibilityStartGeneration = self.generation + 1;
    [self startConfiguredRelay];
  });
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTimeInterval currentTime = [self currentPlaybackTime];
    [self rejectPendingCompatibilityStartWithCode:@"stopped"
                                          message:@"AirPlay relay stopped before handoff completed"
                                       generation:self.pendingCompatibilityStartGeneration];
    self.generation += 1;
    self.stopRelayWhenRouteBecomesLocal = NO;
    if (self.player) {
      [self transitionToState:AirPlaySessionStateStopping
            shouldResumeLocal:YES
                    errorCode:nil
                 errorMessage:nil];
    }
    [self cleanupRelay];
    [self disarmRouteSelection];
    NSError *restoreError = nil;
    BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
    NSString *restoreMessage = restored
        ? nil
        : [self messageByAppendingRestoreError:restoreError
                                     toMessage:nil
                                       context:@"stop"];
    AirPlaySessionState state = [self isAirPlayRouteActive]
        ? AirPlaySessionStateRouteSelected
        : AirPlaySessionStateIdle;
    [self transitionToState:state
          shouldResumeLocal:YES
                  errorCode:restored ? nil : @"restore_audio_session_failed"
               errorMessage:restoreMessage];
    if (!restored) {
      reject(@"airplay_relay_session_error", restoreMessage, restoreError);
      return;
    }
    resolve(@(currentTime));
  });
}

RCT_EXPORT_METHOD(getCurrentTime:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    resolve(@([self currentPlaybackTime]));
  });
}

#pragma mark - Media and route selection

- (BOOL)beginRouteSelectionOperation:(NSError **)error
{
  [self cancelRouteSettlementTimer];
  [self rejectPendingCompatibilityStartWithCode:@"superseded"
                                        message:@"Route selection superseded the pending relay start"
                                     generation:self.pendingCompatibilityStartGeneration];
  if (![self configureRouteSelectionPlaybackSession:error]) {
    return NO;
  }
  BOOL preserveCastingRelay = self.state == AirPlaySessionStateCasting && self.player != nil;
  if (self.state == AirPlaySessionStateStarting) {
    [self cleanupRelay];
  }
  self.generation += 1;
  self.observedGeneration = self.generation;
  if (self.player) {
    [self addProgressObserverForPlayer:self.player generation:self.generation];
  }
  self.routeUIDAtSelectionBegin = [self currentAirPlayRouteUID];
  self.routeSelectionArmed = YES;
  if (preserveCastingRelay) {
    [self emitStateSnapshot];
  } else {
    [self transitionToState:AirPlaySessionStateRouteSelecting
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
  }
  return YES;
}

- (void)disarmRouteSelection
{
  self.routeSelectionArmed = NO;
  self.routeUIDAtSelectionBegin = nil;
}

- (BOOL)storeConfiguredMedia:(NSDictionary *)options error:(NSError **)error
{
  NSString *urlString = [options[@"url"] isKindOfClass:[NSString class]] ? options[@"url"] : nil;
  urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSURL *url = urlString.length > 0 ? [NSURL URLWithString:urlString] : nil;
  if (!url || url.scheme.length == 0) {
    if (error) {
      *error = [NSError errorWithDomain:@"AirPlayRelay"
                                   code:1
                               userInfo:@{NSLocalizedDescriptionKey: @"Missing or invalid AirPlay relay URL"}];
    }
    return NO;
  }

  NSNumber *startTimeValue = [options[@"startTime"] isKindOfClass:[NSNumber class]]
      ? options[@"startTime"]
      : @0;
  NSTimeInterval startTime = startTimeValue.doubleValue;
  if (!isfinite(startTime) || startTime < 0) {
    startTime = 0;
  }
  NSNumber *localWasPlayingValue = [options[@"localWasPlaying"] isKindOfClass:[NSNumber class]]
      ? options[@"localWasPlaying"]
      : @NO;

  NSMutableDictionary *media = [@{
    @"url": urlString,
    @"startTime": @(startTime),
    @"localWasPlaying": @(localWasPlayingValue.boolValue),
  } mutableCopy];
  if ([options[@"title"] isKindOfClass:[NSString class]]) {
    media[@"title"] = options[@"title"];
  }
  if ([options[@"coverUrl"] isKindOfClass:[NSString class]]) {
    media[@"coverUrl"] = options[@"coverUrl"];
  }

  self.configuredMedia = [media copy];
  self.lastKnownTime = startTime;
  self.localWasPlaying = [media[@"localWasPlaying"] boolValue];
  self.shouldResumeLocal = NO;
  self.errorCode = nil;
  self.errorMessage = nil;
  return YES;
}

- (void)finishRouteSelection
{
  BOOL routeActive = [self isAirPlayRouteActive];
  BOOL wasArmed = self.routeSelectionArmed;
  BOOL hadRelayOrStart = self.player != nil ||
      self.state == AirPlaySessionStateStarting ||
      self.state == AirPlaySessionStateCasting ||
      self.state == AirPlaySessionStateStopping;
  NSString *routeUID = [self currentAirPlayRouteUID];
  BOOL isOldSelectionRoute = self.routeUIDAtSelectionBegin.length > 0 &&
      [routeUID isEqualToString:self.routeUIDAtSelectionBegin];

  if (!routeActive && self.stopRelayWhenRouteBecomesLocal) {
    [self stopRelayAfterRouteReturnedLocal];
    return;
  }

  if (routeActive && wasArmed && routeUID.length > 0 && !isOldSelectionRoute) {
    [self handleRouteChanged];
    return;
  }

  if (!routeActive && wasArmed && self.player) {
    [self beginRelayReconfirmationForGeneration:self.generation];
    [self scheduleRouteSettlementForGeneration:self.generation];
    return;
  }

  if (!routeActive && wasArmed &&
      self.state == AirPlaySessionStateRouteSelecting && !self.player) {
    [self scheduleRouteSettlementForGeneration:self.generation];
    return;
  }

  if (!routeActive) {
    if (!wasArmed && !hadRelayOrStart) {
      [self emitStateSnapshot];
      return;
    }
    [self disarmRouteSelection];
    if (hadRelayOrStart) {
      NSUInteger generation = self.generation;
      [self rejectPendingCompatibilityStartWithCode:@"route_lost"
                                            message:@"AirPlay route became local before handoff completed"
                                         generation:generation];
      self.generation += 1;
      [self transitionToState:AirPlaySessionStateStopping
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
      [self cleanupRelay];
      NSError *restoreError = nil;
      BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
      NSString *restoreMessage = restored
          ? nil
          : [self messageByAppendingRestoreError:restoreError
                                       toMessage:nil
                                         context:@"route selection completion"];
      [self transitionToState:AirPlaySessionStateIdle
            shouldResumeLocal:YES
                    errorCode:restored ? nil : @"restore_audio_session_failed"
                 errorMessage:restoreMessage];
    } else {
      [self transitionToState:AirPlaySessionStateIdle
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
    }
    return;
  }

  [self cancelRouteSettlementTimer];

  if (wasArmed && !self.player && (isOldSelectionRoute || routeUID.length == 0)) {
    [self scheduleRouteSettlementForGeneration:self.generation];
    return;
  }

  if (!wasArmed && !self.player) {
    [self emitStateSnapshot];
    return;
  }

  if (wasArmed && self.player) {
    [self scheduleRouteSettlementForGeneration:self.generation];
  }

  if (self.seekCompleted && self.playerItem.status == AVPlayerItemStatusReadyToPlay &&
      self.player.externalPlaybackActive) {
    if (!wasArmed) {
      [self disarmRouteSelection];
    }
    [self cancelStartupTimer];
    self.player.muted = NO;
    [self transitionToState:AirPlaySessionStateCasting
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    [self settlePendingCompatibilityStartForGeneration:self.generation];
    return;
  }

  if (self.player && !self.player.externalPlaybackActive) {
    if (!wasArmed) {
      [self disarmRouteSelection];
    }
    [self beginRelayReconfirmationForGeneration:self.generation];
    return;
  }

  if (!self.player && self.configuredMedia) {
    [self transitionToState:AirPlaySessionStateRouteSelected
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    [self startConfiguredRelay];
    return;
  }

  if (self.state != AirPlaySessionStateStarting) {
    [self transitionToState:AirPlaySessionStateRouteSelected
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
  } else {
    [self emitStateSnapshot];
  }
  if (!(wasArmed && self.player)) {
    [self disarmRouteSelection];
  }
}

#pragma mark - Relay lifecycle

- (void)startConfiguredRelay
{
  NSString *urlString = self.configuredMedia[@"url"];
  NSURL *url = [urlString isKindOfClass:[NSString class]] ? [NSURL URLWithString:urlString] : nil;
  if (!url || url.scheme.length == 0) {
    [self failRelayWithCode:@"invalid_url"
                    message:@"Missing or invalid AirPlay relay URL"
                 generation:self.generation];
    return;
  }

  [self cleanupRelay];
  self.generation += 1;
  NSUInteger generation = self.generation;
  [self disarmRouteSelection];
  self.seekCompleted = NO;

  NSError *sessionError = nil;
  if (![self configureRouteSelectionPlaybackSession:&sessionError]) {
    [self failRelayWithCode:@"audio_session_error"
                    message:sessionError.localizedDescription ?: @"Failed to configure AirPlay audio session"
                 generation:generation];
    return;
  }

  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
  AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
  player.allowsExternalPlayback = YES;
  player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
  player.muted = YES;
  self.playerItem = item;
  self.player = player;

  [self transitionToState:AirPlaySessionStateStarting
        shouldResumeLocal:NO
                errorCode:nil
             errorMessage:nil];
  [self observePlayer:player item:item generation:generation];
  [self addProgressObserverForPlayer:player generation:generation];
  [self startStartupTimerForGeneration:generation];

  NSTimeInterval initialTime = [self.configuredMedia[@"startTime"] doubleValue];
  CMTime seekTime = CMTimeMakeWithSeconds(MAX(initialTime, 0), NSEC_PER_SEC);
  __weak typeof(self) weakSelf = self;
  [player seekToTime:seekTime
      toleranceBefore:kCMTimeZero
       toleranceAfter:kCMTimeZero
    completionHandler:^(BOOL finished) {
      dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || self.generation != generation || self.player != player ||
            self.playerItem != item) {
          return;
        }
        if (!finished) {
          [self failRelayWithCode:@"seek_failed"
                          message:@"AirPlay relay seek did not finish"
                       generation:generation];
          return;
        }
        self.seekCompleted = YES;
        [player play];
        [self evaluateCastingReadinessForGeneration:generation];
      });
    }];
}

- (void)beginRelayReconfirmationForGeneration:(NSUInteger)generation
{
  AVPlayer *player = self.player;
  if (generation != self.generation || !player) {
    return;
  }
  player.muted = YES;
  if (self.state != AirPlaySessionStateStarting) {
    [self transitionToState:AirPlaySessionStateStarting
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
  }
  [self startStartupTimerForGeneration:generation];
}

- (void)evaluateCastingReadinessForGeneration:(NSUInteger)generation
{
  AVPlayer *player = self.player;
  AVPlayerItem *item = self.playerItem;
  if (generation != self.generation || !player || !item) {
    return;
  }

  if (item.status == AVPlayerItemStatusFailed) {
    NSString *message = item.error.localizedDescription ?: @"AirPlay relay item failed";
    [self failRelayWithCode:@"item_failed" message:message generation:generation];
    return;
  }

  if (self.state == AirPlaySessionStateCasting && !player.externalPlaybackActive) {
    player.muted = YES;
    [self transitionToState:AirPlaySessionStateStarting
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    [self startStartupTimerForGeneration:generation];
    return;
  }

  if (!self.seekCompleted) {
    return;
  }

  if (item.status == AVPlayerItemStatusReadyToPlay && player.externalPlaybackActive) {
    [self cancelStartupTimer];
    player.muted = NO;
    [self transitionToState:AirPlaySessionStateCasting
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    [self settlePendingCompatibilityStartForGeneration:generation];
  }
}

- (void)failRelayWithCode:(NSString *)code
                  message:(NSString *)message
               generation:(NSUInteger)generation
{
  if (generation != self.generation) {
    return;
  }
  [self rejectPendingCompatibilityStartWithCode:code
                                        message:message
                                     generation:generation];
  [self currentPlaybackTime];
  self.generation += 1;
  [self cleanupRelay];
  [self disarmRouteSelection];
  NSError *restoreError = nil;
  BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
  NSString *failureMessage = restored
      ? message
      : [self messageByAppendingRestoreError:restoreError
                                   toMessage:message
                                     context:@"relay failure"];
  [self transitionToState:AirPlaySessionStateFailed
        shouldResumeLocal:YES
                errorCode:code
             errorMessage:failureMessage];
}

- (void)cleanupRelay
{
  AVPlayer *player = self.player;
  AVPlayerItem *item = self.playerItem ?: player.currentItem;
  [self currentPlaybackTime];
  [self disarmRouteSelection];
  [self cancelRouteSettlementTimer];
  [self stopObservingPlayerAndItem];
  [self cancelStartupTimer];
  [self removeProgressObserver];
  [player pause];
  player.muted = YES;
  player.allowsExternalPlayback = NO;
  player.usesExternalPlaybackWhileExternalScreenIsActive = NO;
  [item cancelPendingSeeks];
  [item.asset cancelLoading];
  [player replaceCurrentItemWithPlayerItem:nil];
  self.seekCompleted = NO;
  self.playerItem = nil;
  self.player = nil;
}

- (void)stopRelayAfterRouteReturnedLocal
{
  NSUInteger generation = self.generation;
  self.stopRelayWhenRouteBecomesLocal = NO;
  [self rejectPendingCompatibilityStartWithCode:@"route_lost"
                                        message:@"AirPlay route returned to the iPhone"
                                     generation:generation];
  self.generation += 1;
  if (self.player || self.state == AirPlaySessionStateStarting ||
      self.state == AirPlaySessionStateCasting ||
      self.state == AirPlaySessionStateStopping) {
    [self transitionToState:AirPlaySessionStateStopping
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
  }
  [self cleanupRelay];
  [self disarmRouteSelection];
  NSError *restoreError = nil;
  BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
  NSString *restoreMessage = restored
      ? nil
      : [self messageByAppendingRestoreError:restoreError
                                   toMessage:nil
                                     context:@"stop route selection"];
  [self transitionToState:AirPlaySessionStateIdle
        shouldResumeLocal:YES
                errorCode:restored ? nil : @"restore_audio_session_failed"
             errorMessage:restoreMessage];
}

#pragma mark - KVO, progress, and timeout ownership

- (void)observePlayer:(AVPlayer *)player
                  item:(AVPlayerItem *)item
            generation:(NSUInteger)generation
{
  [self stopObservingPlayerAndItem];
  self.observedPlayer = player;
  self.observedItem = item;
  self.observedGeneration = generation;
  [player addObserver:self
           forKeyPath:@"externalPlaybackActive"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:AirPlayExternalPlaybackContext];
  [item addObserver:self
         forKeyPath:@"status"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:AirPlayItemStatusContext];
}

- (void)stopObservingPlayerAndItem
{
  AVPlayer *observedPlayer = self.observedPlayer;
  AVPlayerItem *observedItem = self.observedItem;
  self.observedPlayer = nil;
  self.observedItem = nil;
  self.observedGeneration = 0;
  if (observedPlayer) {
    [observedPlayer removeObserver:self
                        forKeyPath:@"externalPlaybackActive"
                           context:AirPlayExternalPlaybackContext];
  }
  if (observedItem) {
    [observedItem removeObserver:self
                      forKeyPath:@"status"
                         context:AirPlayItemStatusContext];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
  if (context == AirPlayExternalPlaybackContext || context == AirPlayItemStatusContext) {
    if (![NSThread isMainThread]) {
      __weak typeof(self) weakSelf = self;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf handleObservedObject:object context:context];
      });
      return;
    }
    [self handleObservedObject:object context:context];
    return;
  }
  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)handleObservedObject:(id)object context:(void *)context
{
  NSUInteger generation = self.observedGeneration;
  if (generation != self.generation) {
    return;
  }
  if (context == AirPlayExternalPlaybackContext && object != self.observedPlayer) {
    return;
  }
  if (context == AirPlayItemStatusContext && object != self.observedItem) {
    return;
  }
  [self evaluateCastingReadinessForGeneration:generation];
}

- (void)addProgressObserverForPlayer:(AVPlayer *)player generation:(NSUInteger)generation
{
  [self removeProgressObserver];
  __weak typeof(self) weakSelf = self;
  id progressObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(__unused CMTime time) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self || self.generation != generation || self.player != player) {
      return;
    }
    NSTimeInterval currentTime = [self currentPlaybackTime];
    if (self.hasListeners) {
      [self sendEventWithName:@"AirPlayRelayProgress"
                         body:@{@"generation": @(generation), @"currentTime": @(currentTime)}];
    }
  }];
  self.progressObserverPlayer = player;
  self.progressObserver = progressObserver;
}

- (void)removeProgressObserver
{
  id progressObserver = self.progressObserver;
  AVPlayer *observerPlayer = self.progressObserverPlayer;
  self.progressObserver = nil;
  self.progressObserverPlayer = nil;
  if (progressObserver && observerPlayer) {
    [observerPlayer removeTimeObserver:progressObserver];
  }
}

- (void)startStartupTimerForGeneration:(NSUInteger)generation
{
  [self cancelStartupTimer];
  __weak typeof(self) weakSelf = self;
  self.startupTimer = [NSTimer scheduledTimerWithTimeInterval:12.0
                                                      repeats:NO
                                                        block:^(__unused NSTimer *timer) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self || generation != self.generation) {
      return;
    }
    [self failRelayWithCode:@"startup_timeout"
                    message:@"AirPlay relay did not become active in time"
                 generation:generation];
  }];
}

- (void)cancelStartupTimer
{
  [self.startupTimer invalidate];
  self.startupTimer = nil;
}

- (void)scheduleRouteSettlementForGeneration:(NSUInteger)generation
{
  [self cancelRouteSettlementTimer];
  __weak typeof(self) weakSelf = self;
  self.routeSettlementTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                               repeats:NO
                                                                 block:^(NSTimer *timer) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self) {
      return;
    }
    if (self.routeSettlementTimer == timer) {
      self.routeSettlementTimer = nil;
    }
    if (generation != self.generation || !self.routeSelectionArmed) {
      return;
    }
    [self completeRouteSettlementForGeneration:generation];
  }];
}

- (void)completeRouteSettlementForGeneration:(NSUInteger)generation
{
  if (generation != self.generation || !self.routeSelectionArmed) {
    return;
  }
  BOOL routeActive = [self isAirPlayRouteActive];
  NSString *routeUID = [self currentAirPlayRouteUID];
  BOOL isOldSelectionRoute = routeUID.length == 0 ||
      (self.routeUIDAtSelectionBegin.length > 0 &&
       [routeUID isEqualToString:self.routeUIDAtSelectionBegin]);
  if (!routeActive && self.stopRelayWhenRouteBecomesLocal) {
    [self stopRelayAfterRouteReturnedLocal];
    return;
  }
  if (routeActive && isOldSelectionRoute) {
    AVPlayer *player = self.player;
    self.stopRelayWhenRouteBecomesLocal = NO;
    [self disarmRouteSelection];
    if (!player) {
      [self transitionToState:AirPlaySessionStateIdle
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
      return;
    }
    if (self.seekCompleted && self.playerItem.status == AVPlayerItemStatusReadyToPlay &&
        player.externalPlaybackActive) {
      [self cancelStartupTimer];
      player.muted = NO;
      [self transitionToState:AirPlaySessionStateCasting
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
      return;
    }
    [self beginRelayReconfirmationForGeneration:generation];
    return;
  }
  if (routeActive) {
    [self handleRouteChanged];
    return;
  }
  if (!self.player) {
    [self disarmRouteSelection];
    [self transitionToState:AirPlaySessionStateIdle
          shouldResumeLocal:NO
                  errorCode:nil
               errorMessage:nil];
    return;
  }

  [self rejectPendingCompatibilityStartWithCode:@"route_lost"
                                        message:@"AirPlay route remained local after receiver selection"
                                     generation:generation];
  self.generation += 1;
  [self transitionToState:AirPlaySessionStateStopping
        shouldResumeLocal:NO
                errorCode:nil
             errorMessage:nil];
  [self cleanupRelay];
  [self disarmRouteSelection];
  NSError *restoreError = nil;
  BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
  NSString *restoreMessage = restored
      ? nil
      : [self messageByAppendingRestoreError:restoreError
                                   toMessage:nil
                                     context:@"receiver switch settlement"];
  [self transitionToState:AirPlaySessionStateIdle
        shouldResumeLocal:YES
                errorCode:restored ? nil : @"restore_audio_session_failed"
             errorMessage:restoreMessage];
}

- (void)cancelRouteSettlementTimer
{
  [self.routeSettlementTimer invalidate];
  self.routeSettlementTimer = nil;
}

#pragma mark - Compatibility start promise

- (void)settlePendingCompatibilityStartForGeneration:(NSUInteger)generation
{
  if (!self.pendingCompatibilityStartResolve ||
      generation != self.pendingCompatibilityStartGeneration) {
    return;
  }
  RCTPromiseResolveBlock resolve = self.pendingCompatibilityStartResolve;
  [self clearPendingCompatibilityStart];
  resolve([self stateSnapshot]);
}

- (void)rejectPendingCompatibilityStartWithCode:(NSString *)code
                                        message:(NSString *)message
                                     generation:(NSUInteger)generation
{
  if (!self.pendingCompatibilityStartReject ||
      generation != self.pendingCompatibilityStartGeneration) {
    return;
  }
  RCTPromiseRejectBlock reject = self.pendingCompatibilityStartReject;
  [self clearPendingCompatibilityStart];
  NSError *error = [NSError errorWithDomain:@"AirPlayRelay"
                                       code:2
                                   userInfo:@{NSLocalizedDescriptionKey: message ?: @"AirPlay relay start failed"}];
  reject(code, message, error);
}

- (void)clearPendingCompatibilityStart
{
  self.pendingCompatibilityStartResolve = nil;
  self.pendingCompatibilityStartReject = nil;
  self.pendingCompatibilityStartGeneration = 0;
}

#pragma mark - Route notifications

- (void)routeChanged:(__unused NSNotification *)notification
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self handleRouteChanged];
  });
}

- (void)handleRouteChanged
{
  BOOL routeActive = [self isAirPlayRouteActive];
  NSString *routeUID = [self currentAirPlayRouteUID];
  BOOL isOldSelectionRoute = self.routeUIDAtSelectionBegin.length > 0 &&
      [routeUID isEqualToString:self.routeUIDAtSelectionBegin];
  if (!routeActive && self.stopRelayWhenRouteBecomesLocal) {
    [self stopRelayAfterRouteReturnedLocal];
    return;
  }
  if (routeActive && self.routeSelectionArmed && isOldSelectionRoute) {
    [self emitStateSnapshot];
    return;
  }
  if (routeActive && self.routeSelectionArmed && routeUID.length == 0) {
    [self emitStateSnapshot];
    return;
  }
  if (routeActive) {
    [self cancelRouteSettlementTimer];
    if (self.routeSelectionArmed && self.player) {
      self.stopRelayWhenRouteBecomesLocal = NO;
      [self disarmRouteSelection];
      [self beginRelayReconfirmationForGeneration:self.generation];
      [self evaluateCastingReadinessForGeneration:self.generation];
      return;
    }
    if (self.routeSelectionArmed && self.state == AirPlaySessionStateRouteSelecting) {
      [self disarmRouteSelection];
      [self transitionToState:AirPlaySessionStateRouteSelected
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
      if (self.configuredMedia && !self.player) {
        [self startConfiguredRelay];
      }
      return;
    }
    if (self.state == AirPlaySessionStateStarting ||
        self.state == AirPlaySessionStateCasting) {
      [self emitStateSnapshot];
      return;
    }
    [self emitStateSnapshot];
    return;
  }

  if (self.routeSelectionArmed && self.player) {
    [self beginRelayReconfirmationForGeneration:self.generation];
    [self scheduleRouteSettlementForGeneration:self.generation];
    return;
  }

  if (self.state == AirPlaySessionStateStarting ||
      self.state == AirPlaySessionStateCasting ||
      self.state == AirPlaySessionStateStopping || self.player != nil) {
    NSUInteger generation = self.generation;
    [self rejectPendingCompatibilityStartWithCode:@"route_lost"
                                          message:@"AirPlay route became local before handoff completed"
                                       generation:generation];
    self.generation += 1;
    if (self.state != AirPlaySessionStateStopping) {
      [self transitionToState:AirPlaySessionStateStopping
            shouldResumeLocal:NO
                    errorCode:nil
                 errorMessage:nil];
    }
    [self cleanupRelay];
    [self disarmRouteSelection];
    NSError *restoreError = nil;
    BOOL restored = [self restoreLocalPlaybackSession:&restoreError];
    NSString *restoreMessage = restored
        ? nil
        : [self messageByAppendingRestoreError:restoreError
                                     toMessage:nil
                                       context:@"route loss"];
    [self transitionToState:AirPlaySessionStateIdle
          shouldResumeLocal:YES
                  errorCode:restored ? nil : @"restore_audio_session_failed"
               errorMessage:restoreMessage];
    return;
  }

  [self emitStateSnapshot];
}

#pragma mark - Audio session

- (BOOL)configureRouteSelectionPlaybackSession:(NSError **)error
{
  AVAudioSession *session = [AVAudioSession sharedInstance];
  if (![session setCategory:AVAudioSessionCategoryPlayback
                       mode:AVAudioSessionModeDefault
         routeSharingPolicy:AVAudioSessionRouteSharingPolicyLongFormVideo
                    options:0
                      error:error]) {
    return NO;
  }
  return [session setActive:YES error:error];
}

- (BOOL)restoreLocalPlaybackSession:(NSError **)error
{
  return [self configureRouteSelectionPlaybackSession:error];
}

- (NSString *)messageByAppendingRestoreError:(NSError *)restoreError
                                    toMessage:(NSString *)message
                                      context:(NSString *)context
{
  NSString *detail = restoreError.localizedDescription ?: @"Unknown audio session error";
  NSLog(@"[AirPlayRelay] %@ failed in state %@ (generation %lu): %@",
        context,
        [self stringForState:self.state],
        (unsigned long)self.generation,
        detail);
  NSString *restoreMessage = [NSString stringWithFormat:@"Local audio session restore failed: %@", detail];
  return message.length > 0
      ? [NSString stringWithFormat:@"%@; %@", message, restoreMessage]
      : restoreMessage;
}

- (NSString *)currentAirPlayRouteUID
{
  AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
  for (AVAudioSessionPortDescription *output in route.outputs) {
    if ([output.portType isEqualToString:AVAudioSessionPortAirPlay]) {
      return output.UID;
    }
  }
  return nil;
}

- (BOOL)isAirPlayRouteActive
{
  AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
  for (AVAudioSessionPortDescription *output in route.outputs) {
    if ([output.portType isEqualToString:AVAudioSessionPortAirPlay]) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - State snapshots

- (NSString *)stringForState:(AirPlaySessionState)state
{
  switch (state) {
    case AirPlaySessionStateIdle: return @"idle";
    case AirPlaySessionStateRouteSelecting: return @"routeSelecting";
    case AirPlaySessionStateRouteSelected: return @"routeSelected";
    case AirPlaySessionStateStarting: return @"starting";
    case AirPlaySessionStateCasting: return @"casting";
    case AirPlaySessionStateStopping: return @"stopping";
    case AirPlaySessionStateFailed: return @"failed";
  }
}

- (NSTimeInterval)currentPlaybackTime
{
  AVPlayer *player = self.player;
  if (player) {
    CMTime time = player.currentTime;
    if (CMTIME_IS_NUMERIC(time)) {
      NSTimeInterval seconds = CMTimeGetSeconds(time);
      if (isfinite(seconds) && seconds >= 0) {
        self.lastKnownTime = seconds;
      }
    }
  }
  if (!isfinite(self.lastKnownTime) || self.lastKnownTime < 0) {
    self.lastKnownTime = 0;
  }
  return self.lastKnownTime;
}

- (NSDictionary *)stateSnapshot
{
  BOOL routeActive = [self isAirPlayRouteActive];
  BOOL externalPlaybackActive = self.player.externalPlaybackActive;
  NSMutableDictionary *snapshot = [@{
    @"generation": @(self.generation),
    @"state": [self stringForState:self.state],
    @"routeActive": @(routeActive),
    @"externalPlaybackActive": @(externalPlaybackActive),
    @"isCasting": @(self.state == AirPlaySessionStateCasting),
    @"currentTime": @([self currentPlaybackTime]),
    @"shouldResumeLocal": @(self.shouldResumeLocal),
  } mutableCopy];
  if (self.errorCode.length > 0) {
    snapshot[@"errorCode"] = self.errorCode;
  }
  if (self.errorMessage.length > 0) {
    snapshot[@"errorMessage"] = self.errorMessage;
  }
  return [snapshot copy];
}

- (NSDictionary *)compatibilityRouteSnapshot
{
  NSMutableDictionary *snapshot = [[self stateSnapshot] mutableCopy];
  snapshot[@"active"] = @([self isAirPlayRouteActive]);
  return [snapshot copy];
}

- (void)transitionToState:(AirPlaySessionState)state
        shouldResumeLocal:(BOOL)shouldResumeLocal
                errorCode:(NSString *)errorCode
             errorMessage:(NSString *)errorMessage
{
  self.state = state;
  self.shouldResumeLocal = shouldResumeLocal;
  self.errorCode = errorCode;
  self.errorMessage = errorMessage;
  [self emitStateSnapshot];
}

- (void)emitStateSnapshot
{
  if (self.hasListeners) {
    [self sendEventWithName:@"AirPlayRelayStateChanged" body:[self stateSnapshot]];
  }
}

@end
