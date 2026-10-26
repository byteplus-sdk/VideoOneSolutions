import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const nativeRelaySource = readFileSync(
  new URL("../ios/videoonern/AirPlayRelay.m", import.meta.url),
  "utf8",
);
const airPlayRelayBridgeSource = readFileSync(
  new URL("../components/cast/AirPlayRelay.ts", import.meta.url),
  "utf8",
);
const useCastSource = readFileSync(
  new URL("../hooks/useCast.ts", import.meta.url),
  "utf8",
);
const videoPlayerSource = readFileSync(
  new URL("../components/player/VideoPlayer.tsx", import.meta.url),
  "utf8",
);

test("native relay declares the authoritative AirPlay session states", () => {
  assert.match(
    nativeRelaySource,
    /typedef NS_ENUM\(NSInteger, AirPlaySessionState\)\s*\{\s*AirPlaySessionStateIdle,\s*AirPlaySessionStateRouteSelecting,\s*AirPlaySessionStateRouteSelected,\s*AirPlaySessionStateStarting,\s*AirPlaySessionStateCasting,\s*AirPlaySessionStateStopping,\s*AirPlaySessionStateFailed,?\s*\};/,
  );
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, assign\) AirPlaySessionState state;/,
  );
  assert.match(nativeRelaySource, /@property\(nonatomic, assign\) NSUInteger generation;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) AVPlayer \*player;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) AVPlayerItem \*playerItem;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) NSTimer \*startupTimer;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) NSDictionary \*configuredMedia;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, assign\) BOOL routeSelectionArmed;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, assign\) BOOL hasListeners;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, assign\) BOOL localWasPlaying;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, assign\) NSTimeInterval lastKnownTime;/);
});

test("native relay emits one state event and a separate progress event", () => {
  assert.match(
    nativeRelaySource,
    /return @\[@"AirPlayRelayStateChanged", @"AirPlayRelayProgress"\];/,
  );
  assert.doesNotMatch(nativeRelaySource, /AirPlayRelayRouteChanged/);
});

test("React Native invokes every relay method on the main queue", () => {
  assert.match(
    nativeRelaySource,
    /- \(dispatch_queue_t\)methodQueue\s*\{\s*return dispatch_get_main_queue\(\);\s*\}/,
  );
});

test("deallocation synchronously releases relay state on the main queue", () => {
  assert.match(
    nativeRelaySource,
    /- \(void\)dealloc[\s\S]*if \(\[NSThread isMainThread\]\)[\s\S]*\[self cleanupRelay\];[\s\S]*dispatch_sync\(dispatch_get_main_queue\(\),/,
  );
  assert.match(nativeRelaySource, /__unsafe_unretained AirPlayRelay \*relay = self;/);
  const deallocStart = nativeRelaySource.indexOf("- (void)dealloc");
  const supportedEventsStart = nativeRelaySource.indexOf(
    "- (NSArray<NSString *> *)supportedEvents",
  );
  const dealloc = nativeRelaySource.slice(deallocStart, supportedEventsStart);
  assert.doesNotMatch(dealloc, /dispatch_async/);
});

test("state snapshots expose the complete native contract", () => {
  for (const field of [
    "generation",
    "state",
    "routeActive",
    "externalPlaybackActive",
    "isCasting",
    "currentTime",
    "shouldResumeLocal",
  ]) {
    assert.match(nativeRelaySource, new RegExp(`@"${field}"`));
  }
  assert.match(nativeRelaySource, /@"errorCode"/);
  assert.match(nativeRelaySource, /@"errorMessage"/);
  for (const state of [
    "idle",
    "routeSelecting",
    "routeSelected",
    "starting",
    "casting",
    "stopping",
    "failed",
  ]) {
    assert.match(nativeRelaySource, new RegExp(`return @"${state}"`));
  }
});

test("route selection configures long-form video playback and local restoration is explicit", () => {
  assert.match(
    nativeRelaySource,
    /setCategory:AVAudioSessionCategoryPlayback\s+mode:AVAudioSessionModeDefault\s+routeSharingPolicy:AVAudioSessionRouteSharingPolicyLongFormVideo/,
  );
  assert.match(nativeRelaySource, /- \(BOOL\)restoreLocalPlaybackSession:\(NSError \*\*\)error/);
  assert.match(nativeRelaySource, /RCT_EXPORT_METHOD\(restoreLocalAudioSession:/);
  assert.doesNotMatch(nativeRelaySource, /setActive:NO/);
});

test("casting requires both a ready item and active external playback", () => {
  assert.match(
    nativeRelaySource,
    /item\.status == AVPlayerItemStatusReadyToPlay\s*&&\s*player\.externalPlaybackActive/,
  );
  assert.match(
    nativeRelaySource,
    /player\.muted = NO;[\s\S]*transitionToState:AirPlaySessionStateCasting/,
  );
  assert.doesNotMatch(
    nativeRelaySource,
    /muted\s*=\s*!?\s*\(?\[self isAirPlayRouteActive\]/,
  );
});

test("external playback loss leaves casting muted and starts reconfirmation timeout", () => {
  const readiness = nativeRelaySource.match(
    /- \(void\)evaluateCastingReadinessForGeneration:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  assert.ok(readiness);
  assert.match(
    readiness[1],
    /self\.state == AirPlaySessionStateCasting && !player\.externalPlaybackActive[\s\S]*player\.muted = YES;[\s\S]*transitionToState:AirPlaySessionStateStarting[\s\S]*startStartupTimerForGeneration:generation/,
  );
});

test("endRouteSelection cannot unmute or cast before its seek completes", () => {
  const finishRouteSelection = nativeRelaySource.match(
    /- \(void\)finishRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(finishRouteSelection);
  assert.match(
    finishRouteSelection[1],
    /self\.seekCompleted && self\.playerItem\.status == AVPlayerItemStatusReadyToPlay &&\s*self\.player\.externalPlaybackActive/,
  );
  assert.match(
    finishRouteSelection[1],
    /self\.seekCompleted[\s\S]*self\.player\.muted = NO;[\s\S]*AirPlaySessionStateCasting/,
  );
});

test("local picker dismissal keeps selection armed during a generation-bound grace period", () => {
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, strong\) NSTimer \*routeSettlementTimer;/,
  );
  const finishRouteSelection = nativeRelaySource.match(
    /- \(void\)finishRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(finishRouteSelection);
  assert.match(
    finishRouteSelection[1],
    /!routeActive && wasArmed &&\s*self\.state == AirPlaySessionStateRouteSelecting && !self\.player[\s\S]*scheduleRouteSettlementForGeneration:self\.generation[\s\S]*return;/,
  );
  assert.match(nativeRelaySource, /scheduledTimerWithTimeInterval:1\.5/);
  assert.match(
    nativeRelaySource,
    /generation != self\.generation \|\| !self\.routeSelectionArmed/,
  );
});

test("route settlement is centrally cancelled by new selection, activation, and cleanup", () => {
  const cancellation = nativeRelaySource.match(
    /- \(void\)cancelRouteSettlementTimer\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(cancellation);
  assert.match(cancellation[1], /\[self\.routeSettlementTimer invalidate\];/);
  assert.match(cancellation[1], /self\.routeSettlementTimer = nil;/);

  const begin = nativeRelaySource.match(
    /- \(BOOL\)beginRouteSelectionOperation:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  const cleanup = nativeRelaySource.match(
    /- \(void\)cleanupRelay\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(begin && routeChanged && cleanup);
  assert.match(begin[1], /\[self cancelRouteSettlementTimer\];/);
  assert.match(
    routeChanged[1],
    /if \(routeActive\) \{\s*\[self cancelRouteSettlementTimer\];/,
  );
  assert.match(cleanup[1], /\[self cancelRouteSettlementTimer\];/);
});

test("relay startup has a generation-bound twelve second timeout", () => {
  assert.match(nativeRelaySource, /scheduledTimerWithTimeInterval:12\.0/);
  assert.match(nativeRelaySource, /@"startup_timeout"/);
  assert.match(
    nativeRelaySource,
    /if \(!self \|\| generation != self\.generation\)/,
  );
});

test("all relay resources are released by one idempotent cleanup method", () => {
  const cleanup = nativeRelaySource.match(
    /- \(void\)cleanupRelay\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(cleanup, "cleanupRelay must own all relay resource cleanup");
  const body = cleanup[1];
  assert.match(body, /\[self stopObservingPlayerAndItem\];/);
  assert.match(body, /\[self cancelStartupTimer\];/);
  assert.match(body, /\[self removeProgressObserver\];/);
  assert.match(body, /cancelPendingSeeks/);
  assert.match(body, /cancelLoading/);
  assert.match(body, /replaceCurrentItemWithPlayerItem:nil/);
  assert.match(body, /self\.playerItem = nil;/);
  assert.match(body, /self\.player = nil;/);
  for (const resourceRelease of [
    /cancelPendingSeeks/g,
    /cancelLoading/g,
    /replaceCurrentItemWithPlayerItem:nil/g,
    /self\.playerItem = nil/g,
    /self\.player = nil/g,
  ]) {
    assert.equal(
      nativeRelaySource.match(resourceRelease)?.length,
      1,
      `${resourceRelease.source} must be owned only by cleanupRelay`,
    );
  }
});

test("observer cleanup uses the exact player and item that registered KVO", () => {
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) AVPlayer \*observedPlayer;/);
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) AVPlayerItem \*observedItem;/);
  assert.match(nativeRelaySource, /\[observedPlayer removeObserver:self[\s\S]*context:AirPlayExternalPlaybackContext\];/);
  assert.match(nativeRelaySource, /\[observedItem removeObserver:self[\s\S]*context:AirPlayItemStatusContext\];/);
});

test("periodic progress observers are removed from their creating player", () => {
  assert.match(nativeRelaySource, /@property\(nonatomic, strong\) AVPlayer \*progressObserverPlayer;/);
  assert.match(nativeRelaySource, /\[observerPlayer removeTimeObserver:progressObserver\];/);
});

test("new state machine methods are exported", () => {
  for (const method of [
    "configureMedia",
    "beginRouteSelection",
    "endRouteSelection",
    "getState",
    "restoreLocalAudioSession",
  ]) {
    assert.match(nativeRelaySource, new RegExp(`RCT_EXPORT_METHOD\\(${method}:`));
  }
});

test("relay creation is muted, externally playable, and generation guarded", () => {
  assert.match(nativeRelaySource, /player\.allowsExternalPlayback = YES;/);
  assert.match(nativeRelaySource, /player\.usesExternalPlaybackWhileExternalScreenIsActive = YES;/);
  assert.match(nativeRelaySource, /player\.muted = YES;/);
  assert.match(nativeRelaySource, /self\.generation != generation/);
  assert.match(nativeRelaySource, /self\.player != player/);
  assert.match(nativeRelaySource, /self\.playerItem != item/);
  assert.match(
    nativeRelaySource,
    /- \(void\)handleObservedObject:[\s\S]*generation != self\.generation[\s\S]*object != self\.observedPlayer[\s\S]*object != self\.observedItem/,
  );
});

test("route notifications do not equate a system AirPlay route with casting", () => {
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(routeChanged);
  assert.match(
    routeChanged[1],
    /self\.routeSelectionArmed && self\.state == AirPlaySessionStateRouteSelecting/,
  );
  assert.match(routeChanged[1], /\[self startConfiguredRelay\];/);
  assert.match(
    routeChanged[1],
    /self\.state == AirPlaySessionStateStarting \|\|\s*self\.state == AirPlaySessionStateCasting/,
  );
  assert.doesNotMatch(
    routeChanged[1],
    /transitionToState:AirPlaySessionStateCasting[\s\S]*routeActive/,
  );
  assert.match(
    routeChanged[1],
    /\[self cleanupRelay\];[\s\S]*\[self restoreLocalPlaybackSession:[\s\S]*transitionToState:AirPlaySessionStateIdle[\s\S]*shouldResumeLocal:YES/,
  );
});

test("failures use one cleanup path and preserve resumable local state", () => {
  const failure = nativeRelaySource.match(
    /- \(void\)failRelayWithCode:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  assert.ok(failure);
  assert.match(failure[1], /\[self cleanupRelay\];/);
  assert.match(failure[1], /\[self restoreLocalPlaybackSession:/);
  assert.match(failure[1], /AirPlaySessionStateFailed/);
  assert.match(failure[1], /shouldResumeLocal:YES/);
});

test("legacy exports remain thin compatibility wrappers", () => {
  for (const method of [
    "prepareRouteDetection",
    "refreshRouteState",
    "getRouteState",
    "start",
    "stop",
    "getCurrentTime",
  ]) {
    assert.match(nativeRelaySource, new RegExp(`RCT_EXPORT_METHOD\\(${method}:`));
  }
  assert.match(nativeRelaySource, /RCT_EXPORT_METHOD\(stop:[\s\S]*\[self cleanupRelay\];[\s\S]*resolve\(@\(currentTime\)\);/);
});

test("compatibility start settles only after generation-matched casting confirmation", () => {
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, copy\) RCTPromiseResolveBlock pendingCompatibilityStartResolve;/,
  );
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, copy\) RCTPromiseRejectBlock pendingCompatibilityStartReject;/,
  );
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, assign\) NSUInteger pendingCompatibilityStartGeneration;/,
  );

  const startBegin = nativeRelaySource.indexOf("RCT_EXPORT_METHOD(start:");
  const stopBegin = nativeRelaySource.indexOf("RCT_EXPORT_METHOD(stop:");
  const start = nativeRelaySource.slice(startBegin, stopBegin);
  assert.match(
    start,
    /pendingCompatibilityStartResolve = resolve;[\s\S]*pendingCompatibilityStartReject = reject;[\s\S]*startConfiguredRelay/,
  );
  assert.doesNotMatch(start, /startConfiguredRelay[\s\S]*resolve\(/);
  assert.match(
    nativeRelaySource,
    /transitionToState:AirPlaySessionStateCasting[\s\S]*settlePendingCompatibilityStartForGeneration:generation/,
  );
  assert.match(
    nativeRelaySource,
    /generation != self\.pendingCompatibilityStartGeneration/,
  );
});

test("compatibility start rejects once on failures, route loss, stop, and superseding start", () => {
  const failure = nativeRelaySource.match(
    /- \(void\)failRelayWithCode:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(failure && routeChanged);
  assert.match(
    failure[1],
    /rejectPendingCompatibilityStartWithCode:code[\s\S]*generation:generation/,
  );
  assert.match(
    routeChanged[1],
    /rejectPendingCompatibilityStartWithCode:@"route_lost"/,
  );
  assert.match(nativeRelaySource, /rejectPendingCompatibilityStartWithCode:@"stopped"/);
  assert.match(nativeRelaySource, /rejectPendingCompatibilityStartWithCode:@"superseded"/);
  assert.match(nativeRelaySource, /@"airplay_relay_invalid_url"/);
  assert.match(nativeRelaySource, /@"airplay_relay_route_inactive"/);
  assert.match(
    nativeRelaySource,
    /self\.pendingCompatibilityStartResolve = nil;[\s\S]*self\.pendingCompatibilityStartReject = nil;/,
  );
  assert.equal(
    nativeRelaySource.match(/self\.pendingCompatibilityStartResolve = nil;/g)
      ?.length,
    1,
  );
  assert.equal(
    nativeRelaySource.match(/self\.pendingCompatibilityStartReject = nil;/g)
      ?.length,
    1,
  );
});

test("audio restoration failures are logged and surfaced without hiding relay errors", () => {
  assert.match(nativeRelaySource, /NSLog\(@"\[AirPlayRelay\] %@/);
  assert.match(nativeRelaySource, /@"restore_audio_session_failed"/);
  const failure = nativeRelaySource.match(
    /- \(void\)failRelayWithCode:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  assert.ok(failure);
  assert.match(
    failure[1],
    /messageByAppendingRestoreError:restoreError[\s\S]*errorCode:code[\s\S]*errorMessage:failureMessage/,
  );
});

test("beginning receiver selection preserves an active casting relay", () => {
  const begin = nativeRelaySource.match(
    /- \(BOOL\)beginRouteSelectionOperation:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  assert.ok(begin);
  assert.match(
    begin[1],
    /BOOL preserveCastingRelay = self\.state == AirPlaySessionStateCasting && self\.player != nil;/,
  );
  assert.match(
    begin[1],
    /self\.routeSelectionArmed = YES;[\s\S]*if \(preserveCastingRelay\) \{[\s\S]*emitStateSnapshot[\s\S]*\} else \{[\s\S]*AirPlaySessionStateRouteSelecting/,
  );
  assert.match(
    begin[1],
    /self\.routeUIDAtSelectionBegin = \[self currentAirPlayRouteUID\];/,
  );
});

test("armed transient local route preserves the relay until settlement expires", () => {
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  const settlement = nativeRelaySource.match(
    /- \(void\)completeRouteSettlementForGeneration:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  const finish = nativeRelaySource.match(
    /- \(void\)finishRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(routeChanged && settlement && finish);
  assert.match(
    routeChanged[1],
    /self\.routeSelectionArmed && self\.player[\s\S]*beginRelayReconfirmationForGeneration:self\.generation[\s\S]*scheduleRouteSettlementForGeneration:self\.generation[\s\S]*return;/,
  );
  assert.match(
    settlement[1],
    /\[self cleanupRelay\];[\s\S]*\[self restoreLocalPlaybackSession:&restoreError\][\s\S]*AirPlaySessionStateIdle[\s\S]*shouldResumeLocal:YES/,
  );
  assert.match(
    finish[1],
    /!routeActive && wasArmed && self\.player[\s\S]*beginRelayReconfirmationForGeneration:self\.generation[\s\S]*scheduleRouteSettlementForGeneration:self\.generation[\s\S]*return;/,
  );
});

test("AirPlay receiver identity is captured from the output port UID", () => {
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, copy\) NSString \*routeUIDAtSelectionBegin;/,
  );
  assert.match(
    nativeRelaySource,
    /- \(NSString \*\)currentAirPlayRouteUID[\s\S]*AVAudioSessionPortAirPlay[\s\S]*return output\.UID;/,
  );
});

test("armed route notifications distinguish old and newly selected receiver UIDs", () => {
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(routeChanged);
  assert.match(
    routeChanged[1],
    /NSString \*routeUID = \[self currentAirPlayRouteUID\];[\s\S]*BOOL isOldSelectionRoute = self\.routeUIDAtSelectionBegin\.length > 0 &&[\s\S]*\[routeUID isEqualToString:self\.routeUIDAtSelectionBegin\];/,
  );
  assert.match(
    routeChanged[1],
    /routeActive && self\.routeSelectionArmed && isOldSelectionRoute[\s\S]*emitStateSnapshot[\s\S]*return;/,
  );
  assert.match(
    routeChanged[1],
    /if \(self\.routeSelectionArmed && self\.player\)[\s\S]*\[self disarmRouteSelection\];[\s\S]*beginRelayReconfirmationForGeneration:self\.generation/,
  );
  const oldReceiverBranch = routeChanged[1].indexOf(
    "routeActive && self.routeSelectionArmed && isOldSelectionRoute",
  );
  const firstSettlementCancellation = routeChanged[1].indexOf(
    "[self cancelRouteSettlementTimer]",
  );
  assert.ok(oldReceiverBranch >= 0 && oldReceiverBranch < firstSettlementCancellation);
});

test("picker completion reconfirms an existing relay without losing UID grace", () => {
  const finish = nativeRelaySource.match(
    /- \(void\)finishRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(finish);
  assert.match(
    finish[1],
    /self\.player && !self\.player\.externalPlaybackActive[\s\S]*beginRelayReconfirmationForGeneration:self\.generation[\s\S]*return;/,
  );
  assert.match(
    finish[1],
    /if \(wasArmed && self\.player\) \{[\s\S]*scheduleRouteSettlementForGeneration:self\.generation/,
  );
  assert.match(
    finish[1],
    /routeActive && wasArmed && routeUID\.length > 0 && !isOldSelectionRoute[\s\S]*handleRouteChanged[\s\S]*return;/,
  );
  assert.match(
    finish[1],
    /wasArmed && !self\.player && \(isOldSelectionRoute \|\| routeUID\.length == 0\)[\s\S]*scheduleRouteSettlementForGeneration:self\.generation[\s\S]*return;/,
  );
  assert.match(
    nativeRelaySource,
    /- \(void\)beginRelayReconfirmationForGeneration:[\s\S]*player\.muted = YES;[\s\S]*AirPlaySessionStateStarting[\s\S]*startStartupTimerForGeneration:generation/,
  );
});

test("settlement keeps the old receiver relay but confirms a different UID", () => {
  const settlement = nativeRelaySource.match(
    /- \(void\)completeRouteSettlementForGeneration:[\s\S]*?\{([\s\S]*?)\n\}/,
  );
  assert.ok(settlement);
  assert.match(
    settlement[1],
    /BOOL isOldSelectionRoute =[\s\S]*\[routeUID isEqualToString:self\.routeUIDAtSelectionBegin\]\);[\s\S]*if \(routeActive && isOldSelectionRoute\)[\s\S]*\[self disarmRouteSelection\];[\s\S]*self\.seekCompleted[\s\S]*player\.muted = NO;[\s\S]*AirPlaySessionStateCasting/,
  );
  assert.match(
    settlement[1],
    /if \(routeActive\) \{[\s\S]*\[self handleRouteChanged\];[\s\S]*return;/,
  );
});

test("disarming and cleanup clear the captured receiver UID", () => {
  const disarm = nativeRelaySource.match(
    /- \(void\)disarmRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  const cleanup = nativeRelaySource.match(
    /- \(void\)cleanupRelay\s*\{([\s\S]*?)\n\}/,
  );
  assert.ok(disarm && cleanup);
  assert.match(disarm[1], /self\.routeSelectionArmed = NO;/);
  assert.match(disarm[1], /self\.routeUIDAtSelectionBegin = nil;/);
  assert.match(cleanup[1], /\[self disarmRouteSelection\];/);
});

test("compatibility stop rejects when local audio restoration fails", () => {
  const stopBegin = nativeRelaySource.indexOf("RCT_EXPORT_METHOD(stop:");
  const getCurrentTimeBegin = nativeRelaySource.indexOf(
    "RCT_EXPORT_METHOD(getCurrentTime:",
  );
  const stop = nativeRelaySource.slice(stopBegin, getCurrentTimeBegin);
  assert.match(
    stop,
    /if \(!restored\) \{[\s\S]*reject\(@"airplay_relay_session_error", restoreMessage, restoreError\);[\s\S]*return;[\s\S]*\}[\s\S]*resolve\(@\(currentTime\)\);/,
  );
  assert.match(stop, /rejectPendingCompatibilityStartWithCode:@"stopped"/);
});

test("JavaScript bridge exposes the complete typed AirPlay session contract", () => {
  assert.match(
    airPlayRelayBridgeSource,
    /export type AirPlaySessionState\s*=\s*\|\s*'idle'\s*\|\s*'routeSelecting'\s*\|\s*'routeSelected'\s*\|\s*'starting'\s*\|\s*'casting'\s*\|\s*'stopping'\s*\|\s*'failed'/,
  );
  for (const field of [
    "generation: number",
    "state: AirPlaySessionState",
    "routeActive: boolean",
    "externalPlaybackActive: boolean",
    "isCasting: boolean",
    "currentTime: number",
    "shouldResumeLocal?: boolean",
    "errorCode?: string",
    "errorMessage?: string",
  ]) {
    assert.match(airPlayRelayBridgeSource, new RegExp(field.replace("?", "\\?")));
  }
  for (const field of [
    "url: string",
    "startTime: number",
    "title?: string",
    "coverUrl?: string",
    "localWasPlaying: boolean",
  ]) {
    assert.match(airPlayRelayBridgeSource, new RegExp(field.replace("?", "\\?")));
  }
  for (const method of [
    "configureMedia",
    "beginRouteSelection",
    "endRouteSelection",
    "getState",
    "restoreLocalAudioSession",
    "start",
    "stop",
    "getCurrentTime",
    "getRouteState",
  ]) {
    assert.match(airPlayRelayBridgeSource, new RegExp(`${method}:`));
  }
  assert.match(airPlayRelayBridgeSource, /const IDLE_SNAPSHOT: AirPlaySessionSnapshot/);
});

test("the iOS stop picker makes native teardown authoritative once the route returns local", () => {
  assert.match(
    nativeRelaySource,
    /@property\(nonatomic, assign\) BOOL stopRelayWhenRouteBecomesLocal;/,
  );
  assert.match(nativeRelaySource, /RCT_EXPORT_METHOD\(beginStopRouteSelection:/);
  assert.match(
    airPlayRelayBridgeSource,
    /beginStopRouteSelection: \(\) => Promise<AirPlaySessionSnapshot>;/,
  );
  assert.match(
    airPlayRelayBridgeSource,
    /beginStopRouteSelection\(\) \{\s*return NativeAirPlayRelay\?\.beginStopRouteSelection\(\)/,
  );

  const finish = nativeRelaySource.match(
    /- \(void\)finishRouteSelection\s*\{([\s\S]*?)\n\}/,
  );
  const routeChanged = nativeRelaySource.match(
    /- \(void\)handleRouteChanged\s*\{([\s\S]*?)\n\}/,
  );
  const settlement = nativeRelaySource.match(
    /- \(void\)completeRouteSettlementForGeneration:[\s\S]*?\{([\s\S]*?)\n\}/,
  );

  assert.ok(finish && routeChanged && settlement);
  for (const source of [finish[1], routeChanged[1], settlement[1]]) {
    assert.match(
      source,
      /!routeActive && self\.stopRelayWhenRouteBecomesLocal[\s\S]*stopRelayAfterRouteReturnedLocal/,
    );
  }
});

test("JavaScript bridge forwards native state and progress without normalization", () => {
  assert.match(
    airPlayRelayBridgeSource,
    /addStateListener[\s\S]*addListener\('AirPlayRelayStateChanged', listener\)/,
  );
  assert.match(
    airPlayRelayBridgeSource,
    /addProgressListener[\s\S]*addListener\('AirPlayRelayProgress', listener\)/,
  );
  assert.doesNotMatch(airPlayRelayBridgeSource, /airPlayAutoResumeGuard/);
  assert.doesNotMatch(airPlayRelayBridgeSource, /normalizeAirPlayRouteEvent/);
  assert.doesNotMatch(airPlayRelayBridgeSource, /normalizeActive/);
});

test("legacy JavaScript route APIs adapt snapshots without masking native route state", () => {
  assert.match(
    airPlayRelayBridgeSource,
    /prepareRouteDetection\(\)[\s\S]*return AirPlayRelay\.beginRouteSelection\(\)/,
  );
  assert.match(
    airPlayRelayBridgeSource,
    /refreshRouteState\(\)[\s\S]*AirPlayRelay\.endRouteSelection\(\)[\s\S]*active: snapshot\.routeActive/,
  );
  assert.match(
    airPlayRelayBridgeSource,
    /addRouteListener[\s\S]*active: snapshot\.routeActive[\s\S]*nativeActive: snapshot\.routeActive[\s\S]*shouldResumeLocal: snapshot\.shouldResumeLocal[\s\S]*relayStopped: false/,
  );
  assert.doesNotMatch(airPlayRelayBridgeSource, /let\s+[^;]*(route|active)/i);
});

test("iOS cast controller maps exactly one native snapshot", () => {
  const iosCastStart = useCastSource.indexOf("function useIOSCast()");
  const publicApiStart = useCastSource.indexOf("// ─── Public API", iosCastStart);
  const iosCastSource = useCastSource.slice(iosCastStart, publicApiStart);
  assert.match(
    iosCastSource,
    /useState<AirPlaySessionSnapshot>\(IDLE_SNAPSHOT\)/,
  );
  assert.match(iosCastSource, /AirPlayRelay\.addStateListener\(/);
  assert.match(iosCastSource, /AirPlayRelay\.getState\(\)/);
  assert.match(
    iosCastSource,
    /isConnecting: connectingStates\.has\(snapshot\.state\)/,
  );
  assert.match(iosCastSource, /isConnected: snapshot\.isCasting/);
  assert.match(iosCastSource, /isCasting: snapshot\.isCasting/);
  assert.match(
    iosCastSource,
    /deviceName: snapshot\.isCasting \? 'AirPlay' : undefined/,
  );
  assert.match(iosCastSource, /remotePosition: snapshot\.currentTime/);
  assert.match(
    iosCastSource,
    /event\.generation !== current\.generation[\s\S]*currentTime/,
  );
  assert.match(
    iosCastSource,
    /if \(!snapshotRef\.current\.routeActive\)[\s\S]*const restoredSnapshot = await AirPlayRelay\.restoreLocalAudioSession\(\);[\s\S]*snapshotRef\.current = restoredSnapshot;[\s\S]*setSnapshot\(restoredSnapshot\);/,
  );
  assert.doesNotMatch(iosCastSource, /AirPlayRelay\.stop\(/);
});

test("VideoPlayer follows the native AirPlay session state", () => {
  assert.match(videoPlayerSource, /AirPlayRelay\.configureMedia\(/);
  assert.match(videoPlayerSource, /AirPlayRelay\.addStateListener/);
  assert.match(videoPlayerSource, /snapshot\.state === "casting"/);
  assert.match(videoPlayerSource, /snapshot\.state === "starting"/);
  assert.match(
    videoPlayerSource,
    /airPlaySessionStateRef\.current === "casting" \|\|\s*airPlaySessionStateRef\.current === "stopping"/,
  );
  assert.doesNotMatch(videoPlayerSource, /airPlayRelayingRef/);
  assert.doesNotMatch(videoPlayerSource, /airPlayStoppingRef/);
  assert.doesNotMatch(videoPlayerSource, /airPlayStoppedByUserRef/);
  assert.doesNotMatch(videoPlayerSource, /airPlayRoutePickerGuard/);
  assert.doesNotMatch(videoPlayerSource, /AirPlayRelay\.addRouteListener/);
  assert.doesNotMatch(videoPlayerSource, /AirPlayRelay\.stop\(/);
});
