// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { NativeEventEmitter, NativeModules, Platform } from 'react-native';

export type AirPlaySessionState =
  | 'idle'
  | 'routeSelecting'
  | 'routeSelected'
  | 'starting'
  | 'casting'
  | 'stopping'
  | 'failed';

export type AirPlaySessionSnapshot = {
  generation: number;
  state: AirPlaySessionState;
  routeActive: boolean;
  externalPlaybackActive: boolean;
  isCasting: boolean;
  currentTime: number;
  shouldResumeLocal?: boolean;
  errorCode?: string;
  errorMessage?: string;
};

export type AirPlayMediaOptions = {
  url: string;
  startTime: number;
  title?: string;
  coverUrl?: string;
  localWasPlaying: boolean;
};

export type AirPlayProgressEvent = {
  generation: number;
  currentTime: number;
};

export type AirPlayRouteChangedEvent = {
  active: boolean;
  nativeActive: boolean;
  shouldResumeLocal?: boolean;
  relayStopped: boolean;
};

export type AirPlayRouteState = AirPlaySessionSnapshot & {
  active: boolean;
};

export const IDLE_SNAPSHOT: AirPlaySessionSnapshot = {
  generation: 0,
  state: 'idle',
  routeActive: false,
  externalPlaybackActive: false,
  isCasting: false,
  currentTime: 0,
};

type CompatibilityMediaOptions = Omit<AirPlayMediaOptions, 'localWasPlaying'> & {
  localWasPlaying?: boolean;
};

type AirPlayRelayNativeModule = {
  configureMedia: (
    options: AirPlayMediaOptions,
  ) => Promise<AirPlaySessionSnapshot>;
  beginRouteSelection: () => Promise<AirPlaySessionSnapshot>;
  beginStopRouteSelection: () => Promise<AirPlaySessionSnapshot>;
  endRouteSelection: () => Promise<AirPlaySessionSnapshot>;
  getState: () => Promise<AirPlaySessionSnapshot>;
  restoreLocalAudioSession: () => Promise<AirPlaySessionSnapshot>;

  // Compatibility exports used until the player handoff migrates to snapshots.
  start: (
    options: CompatibilityMediaOptions,
  ) => Promise<AirPlaySessionSnapshot>;
  stop: () => Promise<number>;
  getCurrentTime: () => Promise<number>;
  getRouteState: () => Promise<AirPlayRouteState>;
};

const NativeAirPlayRelay = NativeModules.AirPlayRelay as
  | AirPlayRelayNativeModule
  | undefined;

const emitter =
  Platform.OS === 'ios' && NativeAirPlayRelay
    ? new NativeEventEmitter(NativeAirPlayRelay as any)
    : null;

const emptySubscription = () => ({ remove() {} });

export const AirPlayRelay = {
  isAvailable: Platform.OS === 'ios' && !!NativeAirPlayRelay,

  configureMedia(options: AirPlayMediaOptions) {
    return NativeAirPlayRelay?.configureMedia(options) ??
      Promise.resolve(IDLE_SNAPSHOT);
  },

  beginRouteSelection() {
    return NativeAirPlayRelay?.beginRouteSelection() ??
      Promise.resolve(IDLE_SNAPSHOT);
  },

  beginStopRouteSelection() {
    return NativeAirPlayRelay?.beginStopRouteSelection() ??
      Promise.resolve(IDLE_SNAPSHOT);
  },

  endRouteSelection() {
    return NativeAirPlayRelay?.endRouteSelection() ??
      Promise.resolve(IDLE_SNAPSHOT);
  },

  getState() {
    return NativeAirPlayRelay?.getState() ?? Promise.resolve(IDLE_SNAPSHOT);
  },

  restoreLocalAudioSession() {
    return NativeAirPlayRelay?.restoreLocalAudioSession() ??
      Promise.resolve(IDLE_SNAPSHOT);
  },

  addStateListener(listener: (snapshot: AirPlaySessionSnapshot) => void) {
    return emitter?.addListener('AirPlayRelayStateChanged', listener) ??
      emptySubscription();
  },

  addProgressListener(listener: (event: AirPlayProgressEvent) => void) {
    return emitter?.addListener('AirPlayRelayProgress', listener) ??
      emptySubscription();
  },

  // Compatibility wrappers for the current VideoPlayer and picker call sites.
  start(options: CompatibilityMediaOptions) {
    return NativeAirPlayRelay?.start(options) ?? Promise.resolve(IDLE_SNAPSHOT);
  },

  stop() {
    return NativeAirPlayRelay?.stop() ?? Promise.resolve(0);
  },

  getCurrentTime() {
    return NativeAirPlayRelay?.getCurrentTime() ?? Promise.resolve(0);
  },

  getRouteState() {
    return NativeAirPlayRelay?.getRouteState() ??
      Promise.resolve({ ...IDLE_SNAPSHOT, active: false });
  },

  prepareRouteDetection() {
    return AirPlayRelay.beginRouteSelection();
  },

  refreshRouteState() {
    return AirPlayRelay.endRouteSelection().then((snapshot) => ({
      ...snapshot,
      active: snapshot.routeActive,
    }));
  },

  addRouteListener(listener: (event: AirPlayRouteChangedEvent) => void) {
    return AirPlayRelay.addStateListener((snapshot) => {
      listener({
        active: snapshot.routeActive,
        nativeActive: snapshot.routeActive,
        shouldResumeLocal: snapshot.shouldResumeLocal,
        relayStopped: false,
      });
    });
  },
};
