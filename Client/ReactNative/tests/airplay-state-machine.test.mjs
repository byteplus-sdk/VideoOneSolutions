import test from 'node:test';
import assert from 'node:assert/strict';

import {
  AirPlaySessionState,
  createAirPlaySessionSnapshot,
  reduceAirPlaySession,
  shouldBlockAirPlayExit,
} from '../utils/airPlaySessionState.mjs';

test('active route after route selection becomes route selected without casting', () => {
  const selecting = reduceAirPlaySession(
    {
      ...createAirPlaySessionSnapshot(),
      currentTime: 12,
      shouldResumeLocal: true,
    },
    {
      type: 'BEGIN_ROUTE_SELECTION',
    },
  );
  const selected = reduceAirPlaySession(selecting, {
    type: 'ROUTE_CHANGED',
    routeActive: true,
    currentTime: 99,
  });

  assert.equal(selecting.shouldResumeLocal, false);
  assert.equal(selected.state, AirPlaySessionState.ROUTE_SELECTED);
  assert.equal(selected.routeActive, true);
  assert.equal(selected.isCasting, false);
  assert.equal(selected.currentTime, 12);
  assert.equal(selected.shouldResumeLocal, false);
});

test('external playback ready from an active starting route begins casting', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.STARTING,
    routeActive: true,
  };

  const casting = reduceAirPlaySession(snapshot, {
    type: 'EXTERNAL_PLAYBACK_READY',
  });

  assert.equal(casting.state, AirPlaySessionState.CASTING);
  assert.equal(casting.externalPlaybackActive, true);
  assert.equal(casting.isCasting, true);
});

test('external playback ready from idle is ignored', () => {
  const snapshot = createAirPlaySessionSnapshot();

  const result = reduceAirPlaySession(snapshot, {
    type: 'EXTERNAL_PLAYBACK_READY',
  });

  assert.strictEqual(result, snapshot);
});

test('start failure preserves the active route without reporting casting', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.STARTING,
    routeActive: true,
    currentTime: 25,
  };

  const failed = reduceAirPlaySession(snapshot, {
    type: 'START_FAILED',
    errorCode: 'relay-start-failed',
    currentTime: 99,
  });

  assert.equal(failed.state, AirPlaySessionState.FAILED);
  assert.equal(failed.routeActive, true);
  assert.equal(failed.isCasting, false);
  assert.equal(failed.currentTime, 25);
});

test('start failure after casting is ignored', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.CASTING,
    routeActive: true,
    externalPlaybackActive: true,
    isCasting: true,
  };

  const result = reduceAirPlaySession(snapshot, {
    type: 'START_FAILED',
    errorCode: 'late-start-failure',
  });

  assert.strictEqual(result, snapshot);
});

test('route loss while casting resumes local playback at the latest time', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    generation: 4,
    state: AirPlaySessionState.CASTING,
    routeActive: true,
    externalPlaybackActive: true,
    isCasting: true,
    currentTime: 25,
    shouldResumeLocal: false,
    errorCode: 'stale-error',
  };

  const idle = reduceAirPlaySession(snapshot, {
    type: 'ROUTE_CHANGED',
    routeActive: false,
    currentTime: 27,
  });

  assert.deepEqual(idle, {
    generation: 4,
    state: AirPlaySessionState.IDLE,
    routeActive: false,
    externalPlaybackActive: false,
    isCasting: false,
    currentTime: 27,
    shouldResumeLocal: true,
  });
});

test('starting the relay clears stale external playback without changing time', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.ROUTE_SELECTED,
    routeActive: true,
    externalPlaybackActive: true,
    currentTime: 25,
    shouldResumeLocal: true,
  };

  const starting = reduceAirPlaySession(snapshot, {
    type: 'START_RELAY',
    currentTime: 99,
  });

  assert.equal(starting.state, AirPlaySessionState.STARTING);
  assert.equal(starting.externalPlaybackActive, false);
  assert.equal(starting.isCasting, false);
  assert.equal(starting.shouldResumeLocal, false);
  assert.equal(starting.currentTime, 25);
});

test('starting the relay from idle is ignored', () => {
  const snapshot = createAirPlaySessionSnapshot();

  const result = reduceAirPlaySession(snapshot, {
    type: 'START_RELAY',
  });

  assert.strictEqual(result, snapshot);
});

test('beginning a stop preserves the last known playback time', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.CASTING,
    routeActive: true,
    externalPlaybackActive: true,
    isCasting: true,
    currentTime: 25,
  };

  const stopping = reduceAirPlaySession(snapshot, {
    type: 'BEGIN_STOP',
    currentTime: 99,
  });

  assert.equal(stopping.state, AirPlaySessionState.STOPPING);
  assert.equal(stopping.isCasting, false);
  assert.equal(stopping.currentTime, 25);
});

test('beginning a stop from failed is ignored', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.FAILED,
    routeActive: true,
    errorCode: 'relay-start-failed',
  };

  const result = reduceAirPlaySession(snapshot, {
    type: 'BEGIN_STOP',
  });

  assert.strictEqual(result, snapshot);
});

test('active route updates do not downgrade an in-flight start', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.STARTING,
    routeActive: false,
  };

  const result = reduceAirPlaySession(snapshot, {
    type: 'ROUTE_CHANGED',
    routeActive: true,
  });

  assert.equal(result.state, AirPlaySessionState.STARTING);
  assert.equal(result.routeActive, true);
});

test('active route updates preserve failed state and error details', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.FAILED,
    shouldResumeLocal: true,
    errorCode: 'relay-start-failed',
  };

  const result = reduceAirPlaySession(snapshot, {
    type: 'ROUTE_CHANGED',
    routeActive: true,
  });

  assert.deepEqual(result, {
    ...snapshot,
    routeActive: true,
  });
});

test('AirPlay exit is blocked only while an AirPlay route or transition is active', () => {
  const casting = {
    ...createAirPlaySessionSnapshot(),
    state: AirPlaySessionState.CASTING,
    routeActive: true,
  };

  assert.equal(shouldBlockAirPlayExit(casting), true);
  assert.equal(shouldBlockAirPlayExit(createAirPlaySessionSnapshot()), false);
});

test('stale external playback readiness cannot mutate a newer generation', () => {
  const snapshot = {
    ...createAirPlaySessionSnapshot(),
    generation: 4,
    state: AirPlaySessionState.STARTING,
    routeActive: true,
  };

  const result = reduceAirPlaySession(snapshot, {
    type: 'EXTERNAL_PLAYBACK_READY',
    generation: 3,
  });

  assert.strictEqual(result, snapshot);
});
