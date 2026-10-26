import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';
import ts from 'typescript';

const playerSource = readFileSync(new URL('../components/player/VideoPlayer.tsx', import.meta.url), 'utf8');
const start = playerSource.indexOf('{!(duration < 60 && dramaVideoOrientation !== 1)');
const end = playerSource.indexOf('\n      </View>', start);
assert.ok(start > 0 && end > start);
const progressExpression = playerSource.slice(start + 1, end).trim().slice(0, -1);

function mountProgress() {
  const slots = [];
  let cursor = 0;
  const cleanups = [];
  const seeks = [];
  const locks = [];
  const react = {
    useRef(initial) {
      const index = cursor++;
      return (slots[index] ??= { current: initial });
    },
    useState(initial) {
      const index = cursor++;
      if (!(index in slots)) slots[index] = initial;
      return [slots[index], next => { slots[index] = typeof next === 'function' ? next(slots[index]) : next; }];
    },
    useEffect(effect, deps) {
      const index = cursor++;
      if (!slots[index] || deps.some((value, i) => !Object.is(value, slots[index].deps[i]))) {
        slots[index]?.cleanup?.();
        const cleanup = effect();
        slots[index] = { deps, cleanup };
        cleanups[index] = cleanup;
      }
    },
    useCallback: callback => callback,
    createElement(type, props, ...children) {
      return typeof type === 'function' ? type({ ...props, children }) : { type, props: { ...props, children } };
    },
  };
  function load(path) {
    const code = ts.transpileModule(readFileSync(path, 'utf8'), {
      compilerOptions: { module: ts.ModuleKind.CommonJS, jsx: ts.JsxEmit.React, esModuleInterop: true },
    }).outputText;
    const module = { exports: {} };
    vm.runInNewContext(code, {
      module, exports: module.exports,
      require: name => {
        if (name === 'react') return react;
        if (name === 'react-native') return { View: 'View', StyleSheet: { create: value => value } };
        if (name === 'react-native-progress') return { Bar: 'ProgressBar' };
        throw new Error(`Unexpected dependency: ${name}`);
      },
    });
    return module.exports.default;
  }
  const seekBarPath = new URL('../components/player/SeekBar.tsx', import.meta.url);
  const SeekBar = load(seekBarPath);
  const code = ts.transpileModule(`const element = (${progressExpression}); element;`, {
    compilerOptions: { jsx: ts.JsxEmit.React },
  }).outputText;
  return {
    seeks, locks,
    render(overrides = {}) {
      cursor = 0;
      const element = vm.runInNewContext(code, {
        React: react, View: 'View',
        SeekBar,
        duration: 120, currentTime: 20, dramaVideoOrientation: 1,
        currentOrientation: 1, ScreenOrientation: { Orientation: { PORTRAIT_UP: 1 } },
        styles: {},
        isActive: true, isScreenFocused: true,
        isRemotePlaybackActive: () => false,
        playerRef: { current: {} },
        handleSeek: time => seeks.push(time),
        onSeekingChange: active => locks.push(active),
        ...overrides,
      });
      return element.props.children[0];
    },
    unmount() { cleanups.forEach(cleanup => cleanup?.()); },
  };
}

function touch(locationX) {
  return { nativeEvent: { locationX }, stopPropagation() {} };
}

function prepare(page) {
  const bar = page.render();
  assert.equal(typeof bar.props.onResponderGrant, 'function', 'the progress bar must support dragging');
  bar.props.onLayout({ nativeEvent: { layout: { width: 200 } } });
  return page.render();
}

test('dragging previews progress and seeks once on release without surrendering the gesture', () => {
  const page = mountProgress();
  let bar = prepare(page);
  assert.equal(bar.props.onStartShouldSetResponder(), true);
  bar.props.onResponderGrant(touch(50));
  bar.props.onResponderMove(touch(150));
  assert.deepEqual(page.seeks, []);
  assert.deepEqual(page.locks, [true]);
  bar = page.render({ currentTime: 30 });
  assert.equal(bar.props.children[0].props.children[0].props.progress, 0.75);
  assert.equal(bar.props.onResponderTerminationRequest(), false);
  bar.props.onResponderRelease(touch(150));
  assert.deepEqual(page.seeks, [90]);
  assert.deepEqual(page.locks, [true, false]);
});

test('dragging clamps the seek position to the media bounds', () => {
  const page = mountProgress();
  const bar = prepare(page);
  bar.props.onResponderGrant(touch(-30));
  bar.props.onResponderRelease(touch(-30));
  bar.props.onResponderGrant(touch(250));
  bar.props.onResponderRelease(touch(250));
  assert.deepEqual(page.seeks, [0, 120]);
});

test('cancelling or unmounting a drag releases navigation without seeking', () => {
  const page = mountProgress();
  const bar = prepare(page);
  bar.props.onResponderGrant(touch(50));
  bar.props.onResponderTerminate();
  assert.deepEqual(page.locks, [true, false]);
  bar.props.onResponderGrant(touch(100));
  page.unmount();
  assert.deepEqual(page.locks, [true, false, true, false]);
  assert.deepEqual(page.seeks, []);
});

test('inactive or remotely casting players cannot start a seek', () => {
  const page = mountProgress();
  prepare(page);
  for (const props of [{ isActive: false }, { isScreenFocused: false }, { isRemotePlaybackActive: () => true }]) {
    const bar = page.render(props);
    assert.equal(bar.props.onStartShouldSetResponder(), false);
  }
  assert.deepEqual(page.seeks, []);
  assert.deepEqual(page.locks, []);
});

test('losing the active player cancels a drag and releases the page lock', () => {
  const page = mountProgress();
  const bar = prepare(page);
  bar.props.onResponderGrant(touch(60));
  page.render({ isActive: false });
  bar.props.onResponderRelease(touch(100));
  assert.deepEqual(page.locks, [true, false]);
  assert.deepEqual(page.seeks, []);
});

test('an unavailable duration cannot acquire the seeking gesture', () => {
  const page = mountProgress();
  prepare(page);
  for (const duration of [0, -1, NaN, Infinity]) {
    const bar = page.render({ duration });
    assert.equal(bar.props.onStartShouldSetResponder(), false);
  }
  assert.deepEqual(page.locks, []);
});

function mountNavigationLock(os = 'ios') {
  let seeking = false;
  let prevented = false;
  const options = [];
  const blockedRef = { current: false };
  const module = { exports: {} };
  const code = ts.transpileModule(readFileSync(new URL('../hooks/useSeekGestureLock.ts', import.meta.url), 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS },
  }).outputText;
  vm.runInNewContext(code, {
    module, exports: module.exports,
    require: name => {
      if (name === 'react-native') return { Platform: { OS: os } };
      if (name === '@react-navigation/native') return {
        useNavigation: () => ({ setOptions: value => options.push(value.gestureEnabled) }),
        usePreventRemove: value => { prevented = value; },
      };
      if (name === 'react') return {
        useState: () => [seeking, value => { seeking = value; }],
        useRef: () => blockedRef,
        useCallback: callback => callback,
        useLayoutEffect: effect => effect(),
      };
      throw new Error(`Unexpected dependency: ${name}`);
    },
  });
  return {
    options,
    prevented: () => prevented,
    render: blocked => module.exports.useSeekGestureLock(blocked),
  };
}

test('seeking disables iOS swipe back immediately and blocks route removal until release', () => {
  const page = mountNavigationLock();
  const { onSeekingChange } = page.render(false);
  assert.equal(page.options.at(-1), true);
  onSeekingChange(true);
  assert.equal(page.options.at(-1), false);
  assert.equal(page.render(false).isSeeking, true);
  assert.equal(page.prevented(), true);
  onSeekingChange(false);
  assert.equal(page.render(false).isSeeking, false);
  assert.equal(page.prevented(), false);
  assert.equal(page.options.at(-1), true);
});

test('ending a seek preserves an existing AirPlay navigation restriction', () => {
  const page = mountNavigationLock();
  const { onSeekingChange } = page.render(true);
  onSeekingChange(true);
  page.render(true);
  onSeekingChange(false);
  page.render(true);
  assert.equal(page.options.at(-1), false);
  assert.equal(page.prevented(), false);
});

test('seeking blocks Android route removal without setting iOS gesture options', () => {
  const page = mountNavigationLock('android');
  page.render(false).onSeekingChange(true);
  page.render(false);
  assert.equal(page.prevented(), true);
  assert.deepEqual(page.options, []);
});
