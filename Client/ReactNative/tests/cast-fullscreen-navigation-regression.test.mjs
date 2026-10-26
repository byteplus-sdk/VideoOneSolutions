import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import vm from "node:vm";
import { createCastExitGuard } from "../utils/castExitGuard.mjs";

const dramaPlayerSource = readFileSync(
  new URL("../app/drama_player.tsx", import.meta.url),
  "utf8",
);
const episodePlayerSource = readFileSync(
  new URL("../components/player/EpisodePlayer.tsx", import.meta.url),
  "utf8",
);
const castButtonSource = readFileSync(
  new URL("../components/cast/CastButton.tsx", import.meta.url),
  "utf8",
);
const castActiveOverlaySource = readFileSync(
  new URL("../components/cast/CastActiveOverlay.tsx", import.meta.url),
  "utf8",
);
const useCastSource = readFileSync(
  new URL("../hooks/useCast.ts", import.meta.url),
  "utf8",
);

test("an inactive cast exit guard does not stop casting", async () => {
  const guard = createCastExitGuard();
  let stopCount = 0;

  guard.update(false, () => {
    stopCount += 1;
  });

  assert.equal(await guard.stopForExit(), false);
  assert.equal(stopCount, 0);
});

test("an active cast session is stopped at most once for exit", async () => {
  const guard = createCastExitGuard();
  let stopCount = 0;

  guard.update(true, () => {
    stopCount += 1;
  });

  assert.equal(await guard.stopForExit(), true);
  assert.equal(await guard.stopForExit(), false);
  assert.equal(stopCount, 1);
});

test("the cast exit guard uses the latest stop callback", async () => {
  const guard = createCastExitGuard();
  const calls = [];

  guard.update(true, () => calls.push("stale"));
  guard.update(true, () => calls.push("latest"));

  assert.equal(await guard.stopForExit(), true);
  assert.deepEqual(calls, ["latest"]);
});

test("a new active cast session can be stopped after the previous one", async () => {
  const guard = createCastExitGuard();
  let stopCount = 0;
  const stopCasting = () => {
    stopCount += 1;
  };

  guard.update(true, stopCasting);
  assert.equal(await guard.stopForExit(), true);
  guard.update(false, stopCasting);
  guard.update(true, stopCasting);

  assert.equal(await guard.stopForExit(), true);
  assert.equal(stopCount, 2);
});

test("the drama page owns the cast controller used by episode controls", () => {
  assert.match(dramaPlayerSource, /const castController = useCast\(\);/);
  assert.match(episodePlayerSource, /castController: CastController;/);
  assert.doesNotMatch(
    episodePlayerSource,
    /const\s*\{[^}]*\}\s*=\s*useCast\(\);/s,
  );
  assert.match(castButtonSource, /castController\?: CastController;/);
  assert.match(
    castButtonSource,
    /props\.castController[\s\S]*<AndroidCastButton[\s\S]*castController=\{props\.castController\}/,
  );
  assert.match(
    episodePlayerSource,
    /<CastButton[\s\S]*castController=\{castController\}/,
  );
});

test("opening the iOS route picker does not display the casting overlay", () => {
  const declaration = dramaPlayerSource.match(
    /const isRemotePlaybackActive =([\s\S]*?);/,
  );
  assert.ok(declaration, "expected the page's remote playback condition");

  for (const airPlayRequiresRouteSelection of [false, true]) {
    for (const [isCasting, isConnected, expected] of [
      [false, false, false],
      [true, true, true],
      [true, false, true],
      [false, true, true],
      [0, 0, false],
      [1, 0, true],
      [0, 1, true],
    ]) {
      const actual = vm.runInNewContext(`(${declaration[1]})`, {
        castController: { isCasting, isConnected },
        Platform: { OS: "ios" },
        airPlayRequiresRouteSelection,
      });
      assert.equal(actual, expected,
        `casting=${isCasting}, connected=${isConnected}, exit guard=${airPlayRequiresRouteSelection}`);
    }
  }
});

test("casting renders a page-level overlay and disables episode paging", () => {
  assert.match(
    dramaPlayerSource,
    /scrollEnabled=\{!isLandscape && !isRemotePlaybackActive && !isSeeking\}/,
  );
  assert.match(
    dramaPlayerSource,
    /<EpisodePlayer[\s\S]*castController=\{castController\}/,
  );
  assert.match(
    dramaPlayerSource,
    /!isRemotePlaybackActive\s*&&\s*\([\s\S]*styles\.titleBar/,
  );
  assert.match(
    dramaPlayerSource,
    /<FlatList[\s\S]*?\/>[\s\S]*\{isRemotePlaybackActive && \(\s*<CastActiveOverlay[\s\S]*deviceName=\{castController\.deviceName\}[\s\S]*remotePosition=\{castController\.remotePosition\}[\s\S]*onStop=\{castController\.stopCasting\}/,
  );
  assert.match(
    dramaPlayerSource,
    /useEffect\(\(\) => \{\s*if \(isRemotePlaybackActive\) \{\s*setShowEpisodeSelector\(false\);\s*setShowVipModal\(false\);\s*setShowUnlockMultiple\(false\);/,
  );
  assert.match(
    dramaPlayerSource,
    /<EpisodeSelectorModal[\s\S]*?visible=\{!isRemotePlaybackActive && showEpisodeSelector\}/,
  );
  assert.match(
    dramaPlayerSource,
    /<VipUnlockModal[\s\S]*?visible=\{!isRemotePlaybackActive && showVipModal\}/,
  );
  assert.match(
    dramaPlayerSource,
    /<UnlockMultipleModal[\s\S]*?visible=\{!isRemotePlaybackActive && showUnlockMultiple\}/,
  );
  assert.doesNotMatch(episodePlayerSource, /<CastActiveOverlay/);
  assert.doesNotMatch(episodePlayerSource, /useCast\s*\(/);
  assert.match(
    episodePlayerSource,
    /height:\s*isRemotePlaybackActive\s*\? screenDimensions\.height/,
  );
  assert.match(
    episodePlayerSource,
    /currentOrientation === ScreenOrientation\.Orientation\.PORTRAIT_UP\s*&&\s*!isRemotePlaybackActive\s*&&/,
  );
});

test("the fullscreen casting overlay uses English UI copy", () => {
  assert.doesNotMatch(castActiveOverlaySource, /\p{Script=Han}/u);
  assert.match(castActiveOverlaySource, />Casting to your TV</);
  assert.match(
    castActiveOverlaySource,
    />\s*Playback is running on the selected device\. Controls on this page are temporarily disabled while casting is active\.\s*</,
  );
  assert.match(castActiveOverlaySource, />Casting progress \{formatTime\(remotePosition\)\}</);
  assert.match(castActiveOverlaySource, /accessibilityLabel="Stop casting"/);
  assert.match(castActiveOverlaySource, />Stop casting</);
});

test("iOS picker lifecycle is owned by the native state machine", () => {
  assert.match(castButtonSource, /AirPlayRelay\.beginRouteSelection\(\)/);
  assert.match(castButtonSource, /AirPlayRelay\.endRouteSelection\(\)/);
  assert.match(castActiveOverlaySource, /AirPlayRelay\.beginStopRouteSelection\(\)/);
  assert.match(castActiveOverlaySource, /AirPlayRelay\.endRouteSelection\(\)/);
  assert.doesNotMatch(castActiveOverlaySource, /AirPlayRelay\.stop\(/);
  assert.doesNotMatch(castActiveOverlaySource, /IOSBackButton|onExitIntent|exitRequested/);
  assert.doesNotMatch(castActiveOverlaySource, />\s*Back\s*</);
  assert.doesNotMatch(castButtonSource, /airPlayRoutePickerGuard/);
  assert.doesNotMatch(castActiveOverlaySource, /airPlayRoutePickerGuard/);
  assert.doesNotMatch(castButtonSource, /prepareRouteDetection|refreshRouteState/);
  assert.doesNotMatch(castActiveOverlaySource, /prepareRouteDetection|refreshRouteState/);
});

test("iOS casting overlay only stops casting without queuing page navigation", () => {
  assert.doesNotMatch(
    dramaPlayerSource,
    /<CastActiveOverlay[\s\S]*onExitIntent=\{handleAirPlayExitIntent\}/,
  );
  assert.doesNotMatch(castActiveOverlaySource, /Choose iPhone to exit/);
});

test("casting prevents automatic episode advancement", () => {
  const handleVideoFinishMatch = dramaPlayerSource.match(
    /const handleVideoFinish = useCallback\(\(\) => \{([\s\S]*?)\n  \}, \[([^\]]*)\]\);/,
  );

  assert.ok(handleVideoFinishMatch, "expected the video finish handler");
  assert.match(
    handleVideoFinishMatch[1],
    /^\s*if \(isRemotePlaybackActive\) \{\s*return;\s*\}\s*if \(currentIndex < episodes\.length - 1\)/,
  );
  assert.match(
    handleVideoFinishMatch[1],
    /handleEpisodeChange\(nextIndex, true\)/,
  );
  assert.match(handleVideoFinishMatch[2], /isRemotePlaybackActive/);
});

test("page exit waits until AirPlay returns to the iPhone", () => {
  const handleBackPressMatch = dramaPlayerSource.match(
    /const handleBackPress = useCallback\(async \(\) => \{([\s\S]*?)\n  \}, \[([^\]]*)\]\);/,
  );

  assert.ok(handleBackPressMatch, "expected the drama page back handler");
  const handleBackPressBody = handleBackPressMatch[1];
  assert.match(
    handleBackPressBody,
    /handleAirPlayExitIntent\(\);[\s\S]*return;/,
  );
  assert.match(handleBackPressMatch[2], /isLandscape/);
  assert.match(handleBackPressMatch[2], /handleAirPlayExitIntent/);
  assert.match(handleBackPressMatch[2], /stopCastingForExit/);

  assert.match(
    dramaPlayerSource,
    /import \{\s*CommonActions,\s*useNavigation,\s*type NavigationAction,\s*\} from "@react-navigation\/native";/,
  );
  assert.match(
    dramaPlayerSource,
    /import \{\s*createCastExitGuard,\s*type CastExitGuard,\s*\} from "\.\.\/utils\/castExitGuard\.mjs";/,
  );
  assert.match(dramaPlayerSource, /import \{ AirPlayRelay \} from "\.\.\/components\/cast\/AirPlayRelay";/);
  assert.match(
    dramaPlayerSource,
    /const navigation = useNavigation\(\);/,
  );
  assert.match(
    dramaPlayerSource,
    /const castExitGuardRef = useRef<CastExitGuard \| null>\(null\);\s*if \(castExitGuardRef\.current === null\) \{\s*castExitGuardRef\.current = createCastExitGuard\(\);\s*\}/,
  );
  assert.match(
    dramaPlayerSource,
    /useLayoutEffect\(\(\) => \{\s*castExitGuardRef\.current!?\??\.update\(\s*isRemotePlaybackActive,\s*castController\.stopCasting,?\s*\);\s*\}, \[isRemotePlaybackActive, castController\.stopCasting\]\);/,
  );
  assert.doesNotMatch(
    dramaPlayerSource,
    /if \(castExitGuardRef\.current === null\) \{\s*castExitGuardRef\.current = createCastExitGuard\(\);\s*\}\s*castExitGuardRef\.current\.update/,
  );
  assert.match(
    dramaPlayerSource,
    /const stopCastingForExit = useCallback\(\s*\(\) => castExitGuardRef\.current!\.stopForExit\(\),\s*\[\],?\s*\);/,
  );
  assert.match(dramaPlayerSource, /const pendingAirPlayExitRef = useRef<NavigationAction \| null>\(null\);/);
  assert.doesNotMatch(dramaPlayerSource, /airPlayExitRequested|setAirPlayExitRequested/);
  assert.match(dramaPlayerSource, /pendingAirPlayExitRef\.current = CommonActions\.goBack\(\);/);
  assert.match(dramaPlayerSource, /snapshot\.state === "idle" && !snapshot\.routeActive/);
  assert.match(dramaPlayerSource, /navigation\.dispatch\(pendingAction\)/);
  assert.match(dramaPlayerSource, /useSeekGestureLock\(airPlayRequiresRouteSelection\)/);
  assert.match(
    dramaPlayerSource,
    /event\.preventDefault\(\);[\s\S]*pendingAirPlayExitRef\.current = event\.data\.action;[\s\S]*return;/,
  );
  assert.match(
    dramaPlayerSource,
    /Platform\.OS === "android"[\s\S]*stopCastingForExit\(\);/,
  );
  assert.doesNotMatch(
    dramaPlayerSource,
    /<CastActiveOverlay[\s\S]*onExitIntent=\{handleAirPlayExitIntent\}/,
  );
  assert.doesNotMatch(dramaPlayerSource, /isRemotePlaybackActiveRef/);
  assert.doesNotMatch(dramaPlayerSource, /castControllerRef/);
  assert.doesNotMatch(dramaPlayerSource, /AirPlayRelay\.stop\(/);
});

test("leaving an Android cast session cannot be restored by stale native state", () => {
  assert.match(
    useCastSource,
    /const stopCasting = useCallback\(async \(\) => \{/,
  );
  assert.match(
    useCastSource,
    /androidAutoResumeGuard\.suppressUntilUserIntent\(\);[\s\S]*setState\(DEFAULT_STATE\);[\s\S]*await sessionManager\.endCurrentSession\(true\)/,
  );
  assert.match(
    useCastSource,
    /sessionManager\.getCurrentCastSession\(\)\.then\(\(session: any \| null\) => \{[\s\S]*if \(!androidAutoResumeGuard\.normalizeActive\(!!session\)\) \{[\s\S]*return;[\s\S]*\}/,
  );
  assert.match(
    useCastSource,
    /remoteMediaClient\.onMediaStatusUpdated\(\(mediaStatus: any\) => \{[\s\S]*if \(androidAutoResumeGuard\.isSuppressed\(\)\) \{[\s\S]*return;[\s\S]*\}/,
  );
  assert.match(
    useCastSource,
    /const showCastPicker = useCallback\(\(\) => \{[\s\S]*androidAutoResumeGuard\.allowUserIntent\(\);/,
  );
});

test("android cast media listeners are attached only after a session exists", () => {
  assert.doesNotMatch(
    useCastSource,
    /const remoteMediaClient = RemoteMediaClientClass\.current[\s\S]*new RemoteMediaClientClass\.current\(\)/,
  );
  assert.match(
    useCastSource,
    /const attachRemoteMediaListeners = useCallback\(\(remoteMediaClient: any\) => \{/,
  );
  assert.match(
    useCastSource,
    /const remoteMediaClient = session\.getClient\(\);[\s\S]*attachRemoteMediaListeners\(remoteMediaClient\);/,
  );
  assert.match(
    useCastSource,
    /sessionManager\.onSessionEnding\(\(\) => \{[\s\S]*clearRemoteMediaListeners\(\);[\s\S]*\}\)/,
  );
  assert.match(
    useCastSource,
    /sessionManager\.onSessionEnded\(\(\) => \{[\s\S]*setState\(DEFAULT_STATE\);/,
  );
});

test("android pauses local playback while the cast session is connecting", () => {
  assert.match(
    episodePlayerSource,
    /const \{ isConnecting, isCasting, isConnected, remotePosition \} =\s*castController;/,
  );
  assert.match(
    episodePlayerSource,
    /isRemoteCasting=\{\s*Platform\.OS === "android" &&\s*\(isConnecting \|\| isRemotePlaybackActive\)\s*\}/,
  );
});
