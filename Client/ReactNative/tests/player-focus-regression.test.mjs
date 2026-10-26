import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';
import ts from 'typescript';

const source = readFileSync(new URL('../components/player/VideoPlayer.tsx', import.meta.url), 'utf8');

// Execute the actual component effects, mocking only React registration and native APIs.
function runEffect(startMarker, endMarker, bindings) {
  const start = source.indexOf(startMarker);
  const end = source.indexOf(endMarker, start);
  assert.ok(start >= 0 && end > start);
  const code = ts.transpileModule(source.slice(start, end), {
    compilerOptions: { target: ts.ScriptTarget.ES2022 },
  }).outputText;
  return vm.runInNewContext(code, bindings);
}

function appStatePlayer({ focused = true, active = true, casting = false } = {}) {
  let listener;
  let plays = 0;
  let pauses = 0;
  const focus = { current: focused };
  runEffect('// Handle app state changes', '  useFocusEffect(', {
    useEffect: (effect) => effect(),
    AppState: { addEventListener: (_, callback) => { listener = callback; } },
    playerRef: { current: { play: () => plays++, pause: () => pauses++ } },
    isPlayingRef: { current: false },
    isActiveRef: { current: active },
    isScreenFocusedRef: focus,
    shouldPauseLocalPlayback: () => casting,
    onPlayPause: undefined,
  });
  return { emit: (state) => listener(state), focus, plays: () => plays, pauses: () => pauses };
}

test('returning from the AirPlay picker resumes only the visible page', () => {
  const feed = appStatePlayer({ focused: false });
  const detail = appStatePlayer();
  feed.emit('active');
  detail.emit('active');
  assert.equal(feed.plays(), 0, 'the retained feed must remain silent');
  assert.equal(detail.plays(), 1);
});

test('foreground handler reads current focus after navigation', () => {
  const player = appStatePlayer();
  player.focus.current = false;
  player.emit('active');
  assert.equal(player.plays(), 0);
  player.focus.current = true;
  player.emit('active');
  player.emit('background');
  assert.equal(player.plays(), 1);
  assert.equal(player.pauses(), 1);
});

test('foreground keeps inactive episodes and casting local players paused', () => {
  for (const options of [{ active: false }, { casting: true }]) {
    const player = appStatePlayer(options);
    player.emit('active');
    assert.equal(player.plays(), 0);
  }
});

test('a hidden page cannot overwrite media configured for the AirPlay session', () => {
  const configureCall = source.indexOf('    AirPlayRelay.configureMedia(');
  const start = source.lastIndexOf('  useEffect(() => {', configureCall);
  const end = source.indexOf('  useEffect(() => {', configureCall);
  const code = ts.transpileModule(source.slice(start, end), {
    compilerOptions: { target: ts.ScriptTarget.ES2022 },
  }).outputText;
  for (const focused of [false, true]) {
    let configured = 0;
    vm.runInNewContext(code, {
      useEffect: (effect) => effect(), Platform: { OS: 'ios' },
      isScreenFocused: focused, isActive: true, episode: { vip: false },
      currentPlayInfo: { MainPlayUrl: 'https://example.com/video.mp4' },
      currentTime: 10, dramaTitle: 'Example', dramaCoverUrl: '', isPlaying: true,
      AirPlayRelay: { configureMedia: () => { configured++; return Promise.resolve(); } },
    });
    assert.equal(configured, focused ? 1 : 0);
  }
});

test('blur pauses the native player even before its playing callback arrives', () => {
  let pauses = 0;
  let cleanup;
  runEffect('  useFocusEffect(', '  const videoModel =', {
    useFocusEffect: (effect) => { cleanup = effect(); }, useCallback: (fn) => fn,
    playerRef: { current: { play() {}, pause: () => pauses++ } },
    isActiveRef: { current: true }, isPlayingRef: { current: false },
    shouldPauseLocalPlayback: () => false, setIsPlaying() {}, onPlayPause: undefined,
  });
  cleanup();
  assert.equal(pauses, 1);
});
