// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

/**
 * useCast — unified screen-casting hook
 *
 * Platform strategy
 * ─────────────────
 * Android : react-native-google-cast
 *   • Device discovery + session management via Google Cast SDK
 *   • remoteMediaClient.loadMedia() sends the video URL to the Cast device
 *   • Local player is paused while casting
 *
 * iOS     : custom native AirPlay relay
 *   • AVRoutePickerView displays the system route picker.
 *   • A native AVPlayer relay plays the current URL when AirPlay is active.
 *   • The relay reports progress so the BytePlus player can resume locally.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { Platform } from 'react-native';
import {
  AirPlayRelay,
  IDLE_SNAPSHOT,
  type AirPlaySessionSnapshot,
  type AirPlaySessionState,
} from '../components/cast/AirPlayRelay';
import { androidAutoResumeGuard } from '../utils/castAutoResumeGuard.mjs';

// ─── Types ───────────────────────────────────────────────────────────────────

export interface MediaMetadata {
  title?: string;
  subtitle?: string;
  coverUrl?: string;
}

export interface CastState {
  /** Whether at least one Cast/AirPlay device is available on the network */
  isAvailable: boolean;
  /** Whether a Cast session is currently connecting */
  isConnecting: boolean;
  /** Whether a Cast session is established (Android) or AirPlay is active (iOS) */
  isConnected: boolean;
  /** Whether media is actively being cast */
  isCasting: boolean;
  /** Friendly name of the connected device (Android only) */
  deviceName?: string;
  /** Current playback position reported by the remote device (Android only, seconds) */
  remotePosition: number;
}

export interface CastActions {
  /**
   * Show the platform cast picker:
   *   Android → opens the Google Cast device-list dialog
   *   iOS     → no-op (the AirPlayButton component shows the system picker natively)
   */
  showCastPicker: () => void;

  /**
   * Load media on the remote device and start casting.
   * Android: sends the URL + start position to the Cast receiver.
   * iOS:     no-op (AirPlay transfer is managed by the OS automatically).
   */
  startCasting: (
    url: string,
    position: number,
    metadata?: MediaMetadata,
  ) => Promise<void>;

  /**
   * Update the media source (e.g. when the user switches episodes while casting).
   */
  updateCastMedia: (
    url: string,
    position: number,
    metadata?: MediaMetadata,
  ) => Promise<void>;

  /** Seek the remote player to the given position (seconds). Android only. */
  seekRemote: (position: number) => void;

  /** End the current cast session. */
  stopCasting: () => Promise<void>;
}

export type CastController = CastState & CastActions;

// ─── Helpers ─────────────────────────────────────────────────────────────────

const DEFAULT_STATE: CastState = {
  isAvailable: false,
  isConnecting: false,
  isConnected: false,
  isCasting: false,
  deviceName: undefined,
  remotePosition: 0,
};

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const waitForAndroidSessionToEnd = async (sessionManager: any) => {
  for (const waitMs of [100, 250, 500, 1000]) {
    await delay(waitMs);
    const session = await sessionManager.getCurrentCastSession();
    if (!session) {
      return;
    }
  }
};

// ─── Android implementation ──────────────────────────────────────────────────

function useAndroidCast(): CastState & CastActions {
  const [state, setState] = useState<CastState>(DEFAULT_STATE);

  // Lazy-require to avoid crashing on iOS builds where the native module
  // for Google Cast is not linked.
  const GoogleCast = useRef<any>(null);
  const RemoteMediaClientClass = useRef<any>(null);
  const remoteMediaSubscriptions = useRef<Array<{ remove: () => void }>>([]);

  const clearRemoteMediaListeners = useCallback(() => {
    const subscriptions = remoteMediaSubscriptions.current;
    remoteMediaSubscriptions.current = [];
    subscriptions.forEach((subscription) => {
      try {
        subscription.remove();
      } catch (e) {
        console.warn('[useCast] failed to remove remote media listener:', e);
      }
    });
  }, []);

  const attachRemoteMediaListeners = useCallback((remoteMediaClient: any) => {
    if (!remoteMediaClient || androidAutoResumeGuard.isSuppressed()) {
      return;
    }

    clearRemoteMediaListeners();
    remoteMediaSubscriptions.current = [
      remoteMediaClient.onMediaStatusUpdated((mediaStatus: any) => {
        if (androidAutoResumeGuard.isSuppressed()) {
          return;
        }
        if (!mediaStatus) {
          return;
        }
        setState((s) => ({
          ...s,
          isCasting: true,
          remotePosition: mediaStatus.streamPosition ?? s.remotePosition,
        }));
      }),
      remoteMediaClient.onMediaProgressUpdated((progress: number) => {
        if (androidAutoResumeGuard.isSuppressed()) {
          return;
        }
        setState((s) => ({
          ...s,
          remotePosition: progress ?? s.remotePosition,
        }));
      }),
    ];
  }, [clearRemoteMediaListeners]);

  useEffect(() => {
    try {
      // react-native-google-cast v4 default export
      const googleCastModule = require('react-native-google-cast');
      GoogleCast.current = googleCastModule.default;
      RemoteMediaClientClass.current = googleCastModule.RemoteMediaClient;
    } catch (e) {
      console.warn('[useCast] react-native-google-cast not available:', e);
    }
  }, []);

  // Subscribe to Cast state changes
  useEffect(() => {
    const GC = GoogleCast.current;
    if (!GC) return;

    const subs: Array<{ remove: () => void }> = [];

    try {
      const sessionManager = GC.getSessionManager();

      // Session state
      subs.push(
        sessionManager.onSessionStarting(() => {
          if (androidAutoResumeGuard.isSuppressed()) {
            return;
          }
          setState((s) => ({ ...s, isConnecting: true }));
        }),
      );
      subs.push(
        sessionManager.onSessionStarted((session: any) => {
          if (androidAutoResumeGuard.isSuppressed()) {
            return;
          }
          const remoteMediaClient = session.getClient();
          attachRemoteMediaListeners(remoteMediaClient);
          session.getCastDevice().then((device: { friendlyName?: string } | null) => {
            setState((s) => ({
              ...s,
              isConnecting: false,
              isConnected: true,
              deviceName: device?.friendlyName,
            }));
          });
        }),
      );
      subs.push(
        sessionManager.onSessionResumed((session: any) => {
          if (androidAutoResumeGuard.isSuppressed()) {
            return;
          }
          const remoteMediaClient = session.getClient();
          attachRemoteMediaListeners(remoteMediaClient);
          session.getCastDevice().then((device: { friendlyName?: string } | null) => {
            setState((s) => ({
              ...s,
              isConnecting: false,
              isConnected: true,
              deviceName: device?.friendlyName,
            }));
          });
        }),
      );
      subs.push(
        sessionManager.onSessionEnding(() => {
          clearRemoteMediaListeners();
        }),
      );
      subs.push(
        sessionManager.onSessionEnded(() => {
          androidAutoResumeGuard.normalizeActive(false);
          remoteMediaSubscriptions.current = [];
          setState(DEFAULT_STATE);
        }),
      );
      subs.push(
        sessionManager.onSessionStartFailed(() => {
          setState((s) => ({ ...s, isConnecting: false, isConnected: false }));
        }),
      );

      sessionManager.getCurrentCastSession().then((session: any | null) => {
        if (!androidAutoResumeGuard.normalizeActive(!!session)) {
          return;
        }
        const remoteMediaClient = session.getClient();
        attachRemoteMediaListeners(remoteMediaClient);
        session!.getCastDevice().then((device: { friendlyName?: string } | null) => {
          setState((s) => ({
            ...s,
            isConnecting: false,
            isConnected: true,
            deviceName: device?.friendlyName,
          }));
        });
      });
    } catch (e) {
      console.warn('[useCast] failed to subscribe to Cast events:', e);
    }

    return () => {
      clearRemoteMediaListeners();
      subs.forEach((s) => s.remove());
    };
  }, [attachRemoteMediaListeners, clearRemoteMediaListeners]);

  // ── Actions ──────────────────────────────────────────────────────────────

  const showCastPicker = useCallback(() => {
    androidAutoResumeGuard.allowUserIntent();
    try {
      GoogleCast.current?.showCastDialog();
    } catch (e) {
      console.warn('[useCast] showCastDialog error:', e);
    }
  }, []);

  const buildMediaRequest = (
    url: string,
    position: number,
    metadata?: MediaMetadata,
  ) => ({
    mediaInfo: {
      contentId: url,
      contentUrl: url,
      contentType: inferContentType(url),
      metadata: {
        type: 'movie',
        title: metadata?.title ?? '',
        subtitle: metadata?.subtitle ?? '',
        images: metadata?.coverUrl
          ? [{ url: metadata.coverUrl }]
          : [],
      },
      streamType: 'buffered',
    },
    startTime: Math.max(0, position || 0),
    autoplay: true,
  });

  const inferContentType = (url: string) => {
    const normalizedUrl = url.split('?')[0]?.toLowerCase() ?? '';
    if (normalizedUrl.endsWith('.m3u8')) {
      return 'application/x-mpegURL';
    }
    if (normalizedUrl.endsWith('.mpd')) {
      return 'application/dash+xml';
    }
    if (normalizedUrl.endsWith('.webm')) {
      return 'video/webm';
    }
    return 'video/mp4';
  };

  const loadMediaWithRetry = useCallback(
    async (url: string, position: number, metadata?: MediaMetadata) => {
      const GC = GoogleCast.current;
      if (!GC || !RemoteMediaClientClass.current) return;

      const request = buildMediaRequest(url, position, metadata);
      let lastError: unknown;

      for (const waitMs of [0, 500, 1200]) {
        if (waitMs > 0) {
          await delay(waitMs);
        }
        try {
          const client = new RemoteMediaClientClass.current();
          await client.loadMedia(request);
          return;
        } catch (error) {
          lastError = error;
        }
      }

      throw lastError;
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [],
  );

  const startCasting = useCallback(
    async (url: string, position: number, metadata?: MediaMetadata) => {
      try {
        androidAutoResumeGuard.allowUserIntent();
        await loadMediaWithRetry(url, position, metadata);
        setState((s) => ({ ...s, isCasting: true }));
      } catch (e) {
        console.warn('[useCast] startCasting error:', e);
      }
    },
    [loadMediaWithRetry],
  );

  const updateCastMedia = useCallback(
    async (url: string, position: number, metadata?: MediaMetadata) => {
      try {
        await loadMediaWithRetry(url, position, metadata);
      } catch (e) {
        console.warn('[useCast] updateCastMedia error:', e);
      }
    },
    [loadMediaWithRetry],
  );

  const seekRemote = useCallback((position: number) => {
    if (!RemoteMediaClientClass.current) return;
    try {
      const client = new RemoteMediaClientClass.current();
      client.seek({ position });
    } catch (e) {
      console.warn('[useCast] seekRemote error:', e);
    }
  }, []);

  const stopCasting = useCallback(async () => {
    const GC = GoogleCast.current;
    androidAutoResumeGuard.suppressUntilUserIntent();
    setState(DEFAULT_STATE);
    if (!GC) return;
    try {
      const sessionManager = GC.getSessionManager();
      await sessionManager.endCurrentSession(true);
      await waitForAndroidSessionToEnd(sessionManager);
    } catch (e) {
      console.warn('[useCast] stopCasting error:', e);
    }
  }, []);

  return {
    ...state,
    showCastPicker,
    startCasting,
    updateCastMedia,
    seekRemote,
    stopCasting,
  };
}

// ─── iOS implementation (AirPlay) ────────────────────────────────────────────

const connectingStates = new Set<AirPlaySessionState>([
  'routeSelecting',
  'routeSelected',
  'starting',
]);

function useIOSCast(): CastState & CastActions {
  const [isAvailable, setIsAvailable] = useState(AirPlayRelay.isAvailable);
  const [snapshot, setSnapshot] =
    useState<AirPlaySessionSnapshot>(IDLE_SNAPSHOT);
  const snapshotRef = useRef(snapshot);

  useEffect(() => {
    let mounted = true;
    let receivedStateEvent = false;
    setIsAvailable(AirPlayRelay.isAvailable);

    const stateSub = AirPlayRelay.addStateListener((nextSnapshot) => {
      if (mounted) {
        receivedStateEvent = true;
        snapshotRef.current = nextSnapshot;
        setSnapshot(nextSnapshot);
      }
    });
    const progressSub = AirPlayRelay.addProgressListener((event) => {
      if (!mounted) {
        return;
      }
      setSnapshot((current) => {
        if (event.generation !== current.generation) {
          return current;
        }
        const nextSnapshot = {
          ...current,
          currentTime: event.currentTime,
        };
        snapshotRef.current = nextSnapshot;
        return nextSnapshot;
      });
    });

    AirPlayRelay.getState()
      .then((initialSnapshot) => {
        if (
          mounted &&
          (!receivedStateEvent ||
            initialSnapshot.generation > snapshotRef.current.generation)
        ) {
          snapshotRef.current = initialSnapshot;
          setSnapshot(initialSnapshot);
        }
      })
      .catch((error) => {
        console.warn('[useCast] failed to get initial AirPlay state:', error);
      });

    return () => {
      mounted = false;
      stateSub.remove();
      progressSub.remove();
    };
  }, []);

  const noop = useCallback(async () => {}, []);
  const noopSync = useCallback(() => {}, []);

  const stopCasting = useCallback(async () => {
    if (!snapshotRef.current.routeActive) {
      try {
        const restoredSnapshot = await AirPlayRelay.restoreLocalAudioSession();
        snapshotRef.current = restoredSnapshot;
        setSnapshot(restoredSnapshot);
      } catch (error) {
        console.warn('[useCast] failed to restore local audio session:', error);
      }
    }
  }, []);

  return {
    isAvailable,
    isConnecting: connectingStates.has(snapshot.state),
    isConnected: snapshot.isCasting,
    isCasting: snapshot.isCasting,
    deviceName: snapshot.isCasting ? 'AirPlay' : undefined,
    remotePosition: snapshot.currentTime,
    showCastPicker: noopSync,
    startCasting: noop,
    updateCastMedia: noop,
    seekRemote: noopSync,
    stopCasting,
  };
}

// ─── Public API ───────────────────────────────────────────────────────────────

export function useCast(): CastController {
  if (Platform.OS === 'android') {
    // eslint-disable-next-line react-hooks/rules-of-hooks
    return useAndroidCast();
  }
  // eslint-disable-next-line react-hooks/rules-of-hooks
  return useIOSCast();
}

export default useCast;
