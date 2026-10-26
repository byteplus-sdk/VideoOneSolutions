// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import SvgIcon from "@/components/ui/SvgIcon";
import React, {
  useState,
  useRef,
  useMemo,
  useEffect,
  useCallback,
} from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  AppState,
  Platform,
} from "react-native";
import { Image } from "expo-image";
import { useFocusEffect, useIsFocused } from "@react-navigation/native";
import * as ScreenOrientation from "expo-screen-orientation";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import {
  PlayerViewComponent,
  initPlayer,
  createDirectUrlSource,
  FillModeType,
  PlaybackState,
  PlayerLoadState,
  setView,
  getPreRenderEngine,
  getFirstFrameEngine,
  type TTVideoEngine,
} from "../../utils/playerConfig";
import {
  DramaEpisode,
  DramaVideoModel,
  IPlayInfoListItem,
} from "@/types/drama";
import { selectBestPlayInfo } from "@/utils/dramaUtils";
import PlaybackControls from "./PlaybackControls";
import SeekBar from "./SeekBar";
import {
  AirPlayRelay,
  type AirPlaySessionSnapshot,
  type AirPlaySessionState,
} from "../cast/AirPlayRelay";

// Get screen dimensions, swap width and height in landscape mode
const getScreenDimensions = () => {
  const { width: screenWidth, height: screenHeight } = Dimensions.get("window");
  return { width: screenWidth, height: screenHeight };
};

interface VideoPlayerProps {
  episode: DramaEpisode;
  dramaTitle: string;
  dramaCoverUrl: string;
  currentIndex: number; // Current active index from FlatList
  episodes?: DramaEpisode[];
  currentEpisodeIndex?: number;
  playerIndex?: number;
  onPlayPause?: (isPlaying: boolean) => void;
  onProgress?: (progress: number) => void;
  onSeekingChange?: (seeking: boolean) => void;
  onError?: (error: string) => void;
  onFullscreen?: (isFullscreen?: boolean, index?: number) => void; // Fullscreen button click callback
  onDidFinish?: () => void; // Callback when video finishes playing
  dramaId?: string;
  dramaVideoOrientation?: number;
  startTime?: number;
  playbackSpeed?: number; // Playback speed
  onSpeedChange?: (speed: number) => void; // Speed change callback
  onEpisodeSelect?: (index: number) => void; // Episode selection callback
  isFeedTab?: boolean; // Feed tab indicator
  // Pre-render related props
  onScrollPreRender?: () => void; // Callback to trigger scroll pre-render
  shouldTriggerScrollPreRender?: boolean; // Flag to trigger scroll pre-render
  /**
   * Fired whenever the active video URL or quality changes.
   * The parent can use this to supply the correct URL to CastButton.
   */
  onPlayUrlChange?: (url: string, currentTime: number) => void;
  /** Android Google Cast state from the parent page. */
  isRemoteCasting?: boolean;
  /** Android remote playback position in seconds. */
  remoteCastPosition?: number;
}

export const VideoPlayer: React.FC<VideoPlayerProps> = ({
  episode,
  dramaTitle,
  dramaCoverUrl,
  currentIndex,
  episodes = [],
  currentEpisodeIndex = 0,
  playerIndex = 0,
  onPlayPause,
  onProgress,
  onSeekingChange,
  onError,
  onFullscreen,
  onDidFinish,
  dramaId = "",
  dramaVideoOrientation = 0,
  startTime = 0,
  playbackSpeed = 1.0,
  onSpeedChange,
  onEpisodeSelect,
  isFeedTab = false,
  onScrollPreRender,
  shouldTriggerScrollPreRender = false,
  onPlayUrlChange,
  isRemoteCasting = false,
  remoteCastPosition = 0,
}) => {
  const insets = useSafeAreaInsets();
  const isScreenFocused = useIsFocused();
  // ensure viewId is unique
  const viewId = useMemo(
    () =>
      `${isFeedTab ? "feed_" : "drama_"}_player_container_${playerIndex}_${
        episode.vid
      }`,
    [isFeedTab, playerIndex, episode.vid],
  );

  // Calculate isActive internally based on playerIndex and currentIndex
  const isActive = useMemo(() => {
    return playerIndex === currentIndex;
  }, [playerIndex, currentIndex]);

  const [isPlaying, setIsPlaying] = useState(false);
  const [showControls, setShowControls] = useState(true);
  const [duration, setDuration] = useState(episode?.duration || 0);
  const [error, setError] = useState<string | null>(null);
  const [showPoster, setShowPoster] = useState(true);
  const [currentTime, setCurrentTime] = useState(0);
  const [canInit, setCanInit] = useState(false);
  const [currentLikeCount, setCurrentLikeCount] = useState(episode?.like || 0);
  const [isLiked, setIsLiked] = useState(false);
  const [currentQuality, setCurrentQuality] = useState<string>("720P");
  const [currentPlayInfo, setCurrentPlayInfo] =
    useState<IPlayInfoListItem | null>(null);
  const [playInfoList, setPlayInfoList] = useState<IPlayInfoListItem[]>([]);
  const [showLoading, setShowLoading] = useState(false);
  const [containerHeight, setContainerHeight] = useState(0);
  const [currentOrientation, setCurrentOrientation] =
    useState<ScreenOrientation.Orientation>(
      ScreenOrientation.Orientation.PORTRAIT_UP,
    );
  const [screenDimensions, setScreenDimensions] = useState(
    getScreenDimensions(),
  );
  // Pre-render related state
  const [hitPreRender, setHitPreRender] = useState(false);
  const [hitPreRenderFirstFrame, setHitPreRenderFirstFrame] = useState(false);
  const stalledTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const currentOrientationRef = useRef<ScreenOrientation.Orientation>(
    ScreenOrientation.Orientation.PORTRAIT_UP,
  );

  // Keep duration in sync with episode metadata
  useEffect(() => {
    setDuration(episode?.duration || 0);
  }, [episode?.duration]);

  // Notify parent when the video URL changes (quality switch, episode switch, etc.)
  // so the parent can pass the correct URL to CastButton.
  useEffect(() => {
    if (currentPlayInfo?.MainPlayUrl) {
      onPlayUrlChange?.(currentPlayInfo.MainPlayUrl, currentTime);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPlayInfo?.MainPlayUrl]);

  useEffect(() => {
    const initializeOrientation = async () => {
      try {
        const orientation = await ScreenOrientation.getOrientationAsync();
        setCurrentOrientation(orientation);
        currentOrientationRef.current = orientation;
      } catch (error) {
        console.error("Failed to get initial orientation:", error);
      }
    };

    initializeOrientation();

    const subscription = ScreenOrientation.addOrientationChangeListener(
      (event) => {
        const newOrientation = event.orientationInfo.orientation;
        const prevOrientation = currentOrientationRef.current;
        if (
          dramaVideoOrientation === 1 &&
          newOrientation === ScreenOrientation.Orientation.PORTRAIT_UP &&
          prevOrientation !== ScreenOrientation.Orientation.PORTRAIT_UP
        ) {
          ScreenOrientation.lockAsync(
            ScreenOrientation.OrientationLock.PORTRAIT_UP,
          );
        }
        setCurrentOrientation(newOrientation);
        currentOrientationRef.current = newOrientation;
        setScreenDimensions(getScreenDimensions());
      },
    );

    return () => {
      subscription.remove();
    };
  }, [dramaVideoOrientation]);
  const playerRef = useRef<TTVideoEngine>(null);
  const isPlayingRef = useRef(false);
  const isActiveRef = useRef(false);
  const isScreenFocusedRef = useRef(isScreenFocused);
  const currentTimeRef = useRef(0);
  const currentPlayUrlRef = useRef<string | undefined>(undefined);
  const airPlaySessionStateRef = useRef<AirPlaySessionState>("idle");
  const airPlayGenerationRef = useRef(0);
  const localWasPlayingBeforeAirPlayRef = useRef(false);
  const localMutedForAirPlayRef = useRef(false);
  const lastAirPlayResumePositionRef = useRef(0);
  const androidCastingRef = useRef(false);
  const androidRemotePositionRef = useRef(0);

  const shouldPauseLocalPlayback = useCallback(
    () =>
      airPlaySessionStateRef.current === "casting" ||
      airPlaySessionStateRef.current === "stopping" ||
      androidCastingRef.current,
    [],
  );

  const isRemotePlaybackActive = useCallback(
    () => shouldPauseLocalPlayback(),
    [shouldPauseLocalPlayback],
  );

  useEffect(() => {
    setCurrentLikeCount(episode?.like || 0);
  }, [episode?.like]);

  useEffect(() => {
    if (playerRef.current && !episode.vip) {
      playerRef.current.setPlaybackSpeed(playbackSpeed);
    }
  }, [playbackSpeed, episode.vip]);

  useEffect(() => {
    isPlayingRef.current = isPlaying;
  }, [isPlaying]);

  useEffect(() => {
    isActiveRef.current = isActive;
  }, [isActive]);

  useEffect(() => {
    isScreenFocusedRef.current = isScreenFocused;
  }, [isScreenFocused]);

  useEffect(() => {
    currentTimeRef.current = currentTime;
  }, [currentTime]);

  useEffect(() => {
    currentPlayUrlRef.current = currentPlayInfo?.MainPlayUrl;
  }, [currentPlayInfo?.MainPlayUrl]);

  useEffect(() => {
    androidRemotePositionRef.current = remoteCastPosition;
  }, [remoteCastPosition]);

  useEffect(() => {
    if (Platform.OS !== "android" || !isActive || episode.vip) {
      return;
    }

    const pauseLocalForCast = async () => {
      if (!playerRef.current) {
        return;
      }
      if (!androidCastingRef.current) {
        androidCastingRef.current = true;
        androidRemotePositionRef.current = currentTimeRef.current;
      }
      await playerRef.current.pause();
      isPlayingRef.current = false;
      setIsPlaying(false);
      onPlayPause?.(false);
    };

    const resumeLocalAfterCast = async () => {
      if (!androidCastingRef.current || !playerRef.current) {
        return;
      }

      androidCastingRef.current = false;
      const resumeTime = Math.max(
        remoteCastPosition || 0,
        androidRemotePositionRef.current || 0,
        currentTimeRef.current || 0,
      );

      playerRef.current.seek(resumeTime, () => {});
      setCurrentTime(resumeTime);
      await playerRef.current.play();
      isPlayingRef.current = true;
      setIsPlaying(true);
      onPlayPause?.(true);
    };

    if (isRemoteCasting) {
      pauseLocalForCast();
    } else {
      resumeLocalAfterCast();
    }
  }, [
    isRemoteCasting,
    remoteCastPosition,
    isActive,
    episode.vip,
    onPlayPause,
  ]);

  useEffect(() => {
    if (
      Platform.OS !== "ios" ||
      !isScreenFocused ||
      !isActive ||
      !currentPlayInfo?.MainPlayUrl ||
      episode.vip
    ) {
      return;
    }

    AirPlayRelay.configureMedia({
      url: currentPlayInfo.MainPlayUrl,
      startTime: currentTime,
      title: dramaTitle,
      coverUrl: dramaCoverUrl,
      localWasPlaying: isPlaying,
    }).catch((error) => {
      console.warn("[VideoPlayer] Failed to configure AirPlay media:", error);
    });
  }, [
    isScreenFocused,
    isActive,
    currentPlayInfo?.MainPlayUrl,
    currentTime,
    isPlaying,
    dramaTitle,
    dramaCoverUrl,
    episode.vip,
  ]);

  useEffect(() => {
    if (
      Platform.OS !== "ios" ||
      !isScreenFocused ||
      !isActive ||
      episode.vip
    ) {
      return;
    }

    let mounted = true;

    const isStaleAirPlayGeneration = (generation: number) =>
      !mounted || airPlayGenerationRef.current !== generation;

    const applyAirPlaySnapshot = async (snapshot: AirPlaySessionSnapshot) => {
      if (snapshot.generation < airPlayGenerationRef.current) {
        return;
      }

      airPlayGenerationRef.current = snapshot.generation;
      airPlaySessionStateRef.current = snapshot.state;

      const player = playerRef.current;
      if (!player) {
        return;
      }

      if (
        snapshot.state === "routeSelecting" ||
        snapshot.state === "routeSelected" ||
        snapshot.state === "starting"
      ) {
        if (!localMutedForAirPlayRef.current) {
          localWasPlayingBeforeAirPlayRef.current = isPlayingRef.current;
          localMutedForAirPlayRef.current = true;
          player.setMuted(true);
        }
        return;
      }

      if (snapshot.state === "casting") {
        lastAirPlayResumePositionRef.current = snapshot.currentTime;
        if (isPlayingRef.current) {
          await player.pause();
          if (isStaleAirPlayGeneration(snapshot.generation)) {
            return;
          }
          isPlayingRef.current = false;
          setIsPlaying(false);
          onPlayPause?.(false);
        }
        return;
      }

      if (snapshot.state === "failed" || snapshot.state === "idle") {
        const shouldRestoreLocal =
          localMutedForAirPlayRef.current ||
          snapshot.shouldResumeLocal ||
          snapshot.state === "failed";
        if (!shouldRestoreLocal) {
          return;
        }

        const resumeTime = Math.max(
          snapshot.currentTime || 0,
          lastAirPlayResumePositionRef.current || 0,
          currentTimeRef.current || 0,
        );

        try {
          await AirPlayRelay.restoreLocalAudioSession();
        } catch (error) {
          console.warn(
            "[VideoPlayer] Failed to restore local AirPlay audio session:",
            error,
          );
        }

        if (isStaleAirPlayGeneration(snapshot.generation)) {
          return;
        }

        player.seek(resumeTime, () => {});
        setCurrentTime(resumeTime);
        player.setMuted(false);
        localMutedForAirPlayRef.current = false;
        lastAirPlayResumePositionRef.current = resumeTime;

        if (
          snapshot.shouldResumeLocal &&
          localWasPlayingBeforeAirPlayRef.current &&
          !isPlayingRef.current
        ) {
          await player.play();
          if (isStaleAirPlayGeneration(snapshot.generation)) {
            return;
          }
          isPlayingRef.current = true;
          setIsPlaying(true);
          onPlayPause?.(true);
        }

        localWasPlayingBeforeAirPlayRef.current = false;
      }
    };

    const stateSub = AirPlayRelay.addStateListener((snapshot) => {
      applyAirPlaySnapshot(snapshot).catch((error) => {
        console.warn("[VideoPlayer] Failed to apply AirPlay state:", error);
      });
    });

    const progressSub = AirPlayRelay.addProgressListener(
      ({ generation, currentTime }) => {
        if (generation === airPlayGenerationRef.current) {
          lastAirPlayResumePositionRef.current = currentTime;
        }
      },
    );

    AirPlayRelay.getState()
      .then((snapshot) => {
        if (mounted) {
          return applyAirPlaySnapshot(snapshot);
        }
      })
      .catch((error) => {
        console.warn("[VideoPlayer] Failed to get AirPlay state:", error);
      });

    return () => {
      mounted = false;
      stateSub.remove();
      progressSub.remove();
      if (localMutedForAirPlayRef.current && playerRef.current) {
        playerRef.current.setMuted(false);
      }
      airPlaySessionStateRef.current = "idle";
      localMutedForAirPlayRef.current = false;
      localWasPlayingBeforeAirPlayRef.current = false;
    };
  }, [isScreenFocused, isActive, episode.vip, onPlayPause]);

  // Handle app state changes (background/foreground)
  useEffect(() => {
    const handleAppStateChange = (nextAppState: string) => {
      if (
        nextAppState === "background" &&
        isPlayingRef.current &&
        playerRef.current &&
        isActiveRef.current
      ) {
        playerRef.current.pause();
        isPlayingRef.current = false;
        onPlayPause?.(false);
      } else if (
        nextAppState === "active" &&
        playerRef.current &&
        isScreenFocusedRef.current &&
        isActiveRef.current &&
        !shouldPauseLocalPlayback()
      ) {
        playerRef.current.play();
        isPlayingRef.current = true;
      }
    };

    const subscription = AppState.addEventListener(
      "change",
      handleAppStateChange,
    );
    return () => subscription?.remove();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useFocusEffect(
    useCallback(() => {
      if (
        playerRef.current &&
        isActiveRef.current &&
        !isPlayingRef.current &&
        !shouldPauseLocalPlayback()
      ) {
        playerRef.current.play();
      }

      return () => {
        // Native playback may start before its state callback reaches JS.
        if (playerRef.current) {
          playerRef.current.pause();
          isPlayingRef.current = false;
          setIsPlaying(false);
          onPlayPause?.(false);
        }
      };
    }, [onPlayPause, shouldPauseLocalPlayback]),
  );

  const videoModel = useMemo(() => {
    let videoModel = null;
    if (episode.vip) {
      return null;
    }
    try {
      videoModel = JSON.parse(episode.video_model) as DramaVideoModel;
    } catch {
      return null;
    }
    return videoModel;
  }, [episode.video_model, episode.vip]);

  const initializeQuality = useCallback(
    (videoModel: DramaVideoModel, selectedPlayInfo: IPlayInfoListItem) => {
      if (videoModel.PlayInfoList && videoModel.PlayInfoList.length > 0) {
        setPlayInfoList(videoModel.PlayInfoList);
        setCurrentQuality(selectedPlayInfo.Definition);
        setCurrentPlayInfo(selectedPlayInfo);
      }
    },
    [],
  );

  const setPlayer = useCallback(async () => {
    if (!playerRef.current && canInit && !episode.vip) {
      setShowPoster(true);
      setShowLoading(false);

      if (!videoModel) {
        setShowLoading(false);
        return;
      }

      try {
        const selectedPlayInfo = selectBestPlayInfo(videoModel, "720p");
        if (!selectedPlayInfo) {
          throw new Error("No play info found for this episode");
        }

        initializeQuality(videoModel, selectedPlayInfo);

        const source = createDirectUrlSource({
          vid: episode.vid,
          url: selectedPlayInfo.MainPlayUrl,
          cacheKey: episode.vid,
        });

        const fillMode =
          dramaVideoOrientation !== 1
            ? FillModeType.FillModeAspectFill
            : FillModeType.FillModeNone;

        // Try to get pre-render engine first
        const preRenderEngine = getPreRenderEngine(source);
        if (preRenderEngine && playerIndex !== 0) {
          console.log(
            "EngineStrategy: hit pre-render engine",
            playerIndex,
            "hitPreRender:",
            !!preRenderEngine,
            "playerIndex:",
            playerIndex,
          );

          setView(preRenderEngine, viewId, fillMode);

          setShowPoster(false);
          setShowLoading(false);
          setHitPreRender(true);
          playerRef.current = preRenderEngine;
        } else {
          const player = await initPlayer({
            viewId,
            fillMode,
          });

          player.setVideoSource(source);
          setHitPreRender(false);
          playerRef.current = player;
        }
        startTime && playerRef.current.setStartTime(startTime);
        playerRef.current.setPlaybackSpeed(playbackSpeed);

        // playerRef.current.setIOSOptionForKey(42866, 1);
        // playerRef.current.setIOSOptionForKey(42627, 1);

        playerRef.current.setListener({
          onReadyToDisplay() {
            setShowLoading(false);
          },
          onCurrentPlaybackTimeUpdate(currentTime: number) {
            setCurrentTime(currentTime);
            currentTimeRef.current = currentTime;
            if (currentTime > 0) {
              setShowPoster(false);
              setShowLoading(false);
            }
            onProgress?.(currentTime);
            if (currentPlayUrlRef.current) {
              onPlayUrlChange?.(currentPlayUrlRef.current, currentTime);
            }
          },
          onPlaybackStateChanged(
            engine: TTVideoEngine,
            playbackState: PlaybackState,
          ) {
            // show play button when paused
            if (playbackState === PlaybackState.PLAYBACK_STATE_PLAYING) {
              if (shouldPauseLocalPlayback()) {
                engine.setMuted(true);
                engine.pause();
                isPlayingRef.current = false;
                setIsPlaying(false);
                onPlayPause?.(false);
                return;
              }
              isPlayingRef.current = true;
              setIsPlaying(true);
              onPlayPause?.(true);
            } else if (playbackState === PlaybackState.PLAYBACK_STATE_PAUSED) {
              isPlayingRef.current = false;
              setIsPlaying(false);
              onPlayPause?.(false);
            } else {
              console.log("Unknown playback state:", playbackState);
            }
          },
          onLoadStateChanged(engine: any, state: number) {
            // Handle stalled state with delay
            if (state === PlayerLoadState.STALLED) {
              stalledTimerRef.current = setTimeout(() => {
                setShowLoading(true);
              }, 200);
            } else {
              // Clear any pending stalled timer
              if (stalledTimerRef.current) {
                clearTimeout(stalledTimerRef.current);
                stalledTimerRef.current = null;
              }

              // Hide loading for playable and error states
              if (
                state === PlayerLoadState.PLAYABLE ||
                state === PlayerLoadState.ERROR
              ) {
                console.log("Setting loading to false for state:", state);
                setShowLoading(false);
              }
            }
          },
          onPrepared() {},
          onError(message: string, code: number) {
            console.error("VideoPlayer: onError", message, code);
            setError(message || "Playback error");
            onError?.(message || "Playback error");
          },
          onDidFinish() {
            setIsPlaying(false);
            onPlayPause?.(false);
            // Only trigger onDidFinish callback for the active player
            if (isActive && !isRemotePlaybackActive()) {
              onDidFinish?.();
            }
          },
          onCacheChange(key: string, cacheSize: number) {
            if (cacheSize > 0) {
              console.log("hit cache may due to preload");
            }
          },
        });

        if (isActive && !shouldPauseLocalPlayback()) {
          playerRef.current.play();
          isPlayingRef.current = true;
          setIsPlaying(true);
        }
      } catch (error) {
        console.error("VideoPlayer: setPlayer error", error);
      }
    }
  }, [
    canInit,
    episode.vip,
    episode.vid,
    videoModel,
    initializeQuality,
    dramaVideoOrientation,
    playerIndex,
    startTime,
    playbackSpeed,
    isActive,
    viewId,
    onProgress,
    onPlayUrlChange,
    onPlayPause,
    onError,
    onDidFinish,
    isRemotePlaybackActive,
    shouldPauseLocalPlayback,
  ]);

  useEffect(() => {
    return () => {
      if (playerRef.current) {
        playerRef.current.close();
        playerRef.current = null;
      }
      if (stalledTimerRef.current) {
        clearTimeout(stalledTimerRef.current);
        stalledTimerRef.current = null;
      }
      // Reset pre-render states
      setHitPreRender(false);
      setHitPreRenderFirstFrame(false);
    };
  }, [episode.vid, playerIndex]);

  useEffect(() => {
    if (!isActive) {
      if (playerRef.current) {
        playerRef.current?.close();
        playerRef.current = null;
      }
      setShowPoster(true);
      setCurrentTime(0);
      setIsPlaying(false);
      setError(null);
      if (stalledTimerRef.current) {
        clearTimeout(stalledTimerRef.current);
        stalledTimerRef.current = null;
      }
      setShowLoading(false);
      // Reset pre-render states when not active
      setHitPreRender(false);
      setHitPreRenderFirstFrame(false);
    } else {
      setShowLoading(true);
      if (!episode.vip) {
        setPlayer();
      }
    }
  }, [canInit, isActive, playerIndex, episode.vip, setPlayer]);

  const handleVideoPress = useCallback(async () => {
    console.log("handleVideoPress", {
      isPlaying,
      showPoster,
      hasPlayer: !!playerRef.current,
    });
    if (isPlaying && playerRef.current) {
      await playerRef.current.pause();
      isPlayingRef.current = false;
      setIsPlaying(false);
    } else if (
      !isPlaying &&
      playerRef.current &&
      !showPoster &&
      !isRemotePlaybackActive()
    ) {
      await playerRef.current.play();
      isPlayingRef.current = true;
      setIsPlaying(true);
    } else {
      setShowControls(!showControls);
    }
  }, [isPlaying, showControls, showPoster, isRemotePlaybackActive]);

  const handlePlayPause = useCallback(async () => {
    if (isRemotePlaybackActive()) {
      return;
    }
    if (playerRef.current) {
      if (isPlaying) {
        await playerRef.current.pause();
        isPlayingRef.current = false;
        setIsPlaying(false);
      } else {
        await playerRef.current.play();
        isPlayingRef.current = true;
        setIsPlaying(true);
      }
    }
  }, [isPlaying, isRemotePlaybackActive]);

  const handleRetry = useCallback(() => {
    if (playerRef.current) {
      playerRef.current.close({ stopPip: false });
      playerRef.current = null;
    }

    if (stalledTimerRef.current) {
      clearTimeout(stalledTimerRef.current);
      stalledTimerRef.current = null;
    }

    setError(null);
    setShowLoading(false);
    setShowPoster(true);
    setCurrentTime(0);
    setIsPlaying(false);
    // Reset pre-render states on retry
    setHitPreRender(false);
    setHitPreRenderFirstFrame(false);

    setPlayer();
  }, [setPlayer]);

  // Scroll-based pre-render logic
  const handleScrollPreRender = useCallback(async () => {
    if (
      canInit &&
      !episode.vip &&
      videoModel &&
      Math.abs(currentIndex - playerIndex) < 2
    ) {
      try {
        const selectedPlayInfo = selectBestPlayInfo(videoModel, "720p");
        if (!selectedPlayInfo) {
          console.warn("VideoPlayer: no play info found for scroll pre-render");
          return;
        }
        const source = createDirectUrlSource({
          vid: episode.vid,
          url: selectedPlayInfo.MainPlayUrl,
          cacheKey: episode.vid,
        });

        const preRenderEngine = getFirstFrameEngine(source);
        if (preRenderEngine && !hitPreRenderFirstFrame) {
          console.log(
            `VideoPlayer: scroll hit first frame pre-render for ${playerIndex}`,
          );
          setHitPreRenderFirstFrame(true);
          setShowPoster(false);
          const fillMode =
            dramaVideoOrientation !== 1
              ? FillModeType.FillModeAspectFill
              : FillModeType.FillModeNone;
          await setView(preRenderEngine, viewId, fillMode);
        } else {
          console.log(
            `VideoPlayer: scroll not hit first frame pre-render for ${playerIndex}`,
          );
        }
      } catch (error) {
        console.warn("VideoPlayer: scroll pre-render error", error);
      }
    }
  }, [
    canInit,
    episode.vip,
    episode.vid,
    videoModel,
    currentIndex,
    playerIndex,
    hitPreRenderFirstFrame,
    dramaVideoOrientation,
    viewId,
  ]);

  // Trigger scroll pre-render when flag changes
  useEffect(() => {
    if (shouldTriggerScrollPreRender) {
      handleScrollPreRender();
    }
  }, [shouldTriggerScrollPreRender, handleScrollPreRender]);

  const getFullscreenButtonPosition = useCallback(() => {
    if (
      !episode.width ||
      !episode.height ||
      dramaVideoOrientation !== 1 ||
      containerHeight === 0
    ) {
      return { bottom: 20 };
    }

    const containerWidth = screenDimensions.width;
    const actualContainerHeight = containerHeight;

    const videoAspectRatio = episode.width / episode.height;
    const containerAspectRatio = containerWidth / actualContainerHeight;

    let videoRenderHeight, offsetY;

    if (videoAspectRatio > containerAspectRatio) {
      videoRenderHeight = containerWidth / videoAspectRatio;
      offsetY = (actualContainerHeight - videoRenderHeight) / 2;
    } else {
      videoRenderHeight = actualContainerHeight;
      offsetY = 0;
    }

    const buttonBottom = offsetY + videoRenderHeight + 10;

    return {
      top: Math.max(20, buttonBottom),
    };
  }, [
    episode.width,
    episode.height,
    dramaVideoOrientation,
    containerHeight,
    screenDimensions.width,
  ]);

  const handleContainerLayout = useCallback((event: any) => {
    const { height } = event.nativeEvent.layout;
    setContainerHeight(height);
  }, []);

  const handleFullscreenPress = useCallback(async () => {
    try {
      const isPortrait =
        currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP;

      const goingToFullscreen = isPortrait; // portrait -> landscape means entering fullscreen
      if (isPortrait) {
        await ScreenOrientation.lockAsync(
          ScreenOrientation.OrientationLock.LANDSCAPE_RIGHT,
        );
      } else {
        await ScreenOrientation.lockAsync(
          ScreenOrientation.OrientationLock.PORTRAIT_UP,
        );
      }

      onFullscreen?.(goingToFullscreen, currentIndex);
    } catch {
      // Even if locking fails, notify parent with intended state based on current orientation
      const isPortrait =
        currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP;
      const goingToFullscreen = isPortrait;
      onFullscreen?.(goingToFullscreen, currentIndex);
    }
  }, [onFullscreen, currentOrientation, currentIndex]);

  const handleSeek = useCallback(
    (targetTime: number) => {
      if (duration <= 0 || !playerRef.current || !isActive || !isScreenFocused || isRemotePlaybackActive()) {
        return;
      }
      const clampedTime = Math.max(0, Math.min(duration, targetTime));

      playerRef.current.seek(clampedTime, (success: boolean) => {
        console.log(
          `VideoPlayer: seek to ${clampedTime}, ${
            success ? "success" : "failed"
          }`,
        );
      });
      setCurrentTime(clampedTime);
      currentTimeRef.current = clampedTime;
      onProgress?.(clampedTime);
    },
    [duration, isActive, isScreenFocused, isRemotePlaybackActive, onProgress],
  );

  const handleLikePress = useCallback(() => {
    const newLikedState = !isLiked;
    const newCount = newLikedState
      ? currentLikeCount + 1
      : Math.max(0, currentLikeCount - 1);

    setIsLiked(newLikedState);
    setCurrentLikeCount(newCount);
  }, [isLiked, currentLikeCount]);

  const handleLandscapeLikePress = useCallback(() => {
    handleLikePress();
  }, [handleLikePress]);

  const handleCommentPress = useCallback(() => {
    // TODO something
  }, []);

  const handleQualityChange = useCallback(
    async (quality: string, playInfo: IPlayInfoListItem) => {
      if (!playerRef.current || !currentPlayInfo) {
        return;
      }

      try {
        const currentTime = await playerRef.current.getCurrentPlaybackTime();
        const newSource = createDirectUrlSource({
          url: playInfo.MainPlayUrl,
          cacheKey: episode.vid,
        });
        playerRef.current.setVideoSource(newSource);
        await playerRef.current.setStartTime(currentTime);
        if (!shouldPauseLocalPlayback()) {
          console.warn("handleQualityChange play player", playerIndex);
          await playerRef.current.play();
        }
        setCurrentQuality(quality);
        setCurrentPlayInfo(playInfo);
      } catch {
        // process error
      }
    },
    [currentPlayInfo, episode.vid, playerIndex, shouldPauseLocalPlayback],
  );

  const styles = useMemo(
    () =>
      StyleSheet.create({
        container: {
          flex: 1,
          backgroundColor: "#000",
          flexDirection: "column",
        },
        errorContainer: {
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: "#000",
          paddingHorizontal: 32,
        },
        errorText: {
          color: "#fff",
          fontSize: 16,
          textAlign: "center",
          marginBottom: 32,
          lineHeight: 22,
          fontWeight: "400",
        },
        retryButton: {
          backgroundColor: "rgba(255, 255, 255, 0.15)",
          paddingHorizontal: 24,
          paddingVertical: 6,
          borderRadius: 8,
          flexDirection: "row",
          alignItems: "center",
          borderWidth: 1,
          borderColor: "rgba(255, 255, 255, 0.2)",
        },
        retryButtonText: {
          color: "#fff",
          fontSize: 16,
          fontWeight: "500",
          marginLeft: 8,
        },
        refreshIcon: {
          width: 18,
          height: 18,
          marginRight: 4,
        },
        videoTouchable: {
          flex: 1,
          position: "relative",
        },
        player: {
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        },
        coverContainer: {
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          zIndex: 5,
        },
        coverImage: {
          width: "100%",
          height: "100%",
        },
        coverOverlay: {
          ...StyleSheet.absoluteFillObject,
          backgroundColor: "rgba(0, 0, 0, 0.3)",
        },
        bottomProgressBar: {
          position: "absolute",
          bottom: 0,
          left: 16,
          right: 16,
          height: 44,
          justifyContent: "center",
          zIndex: 100,
        },
        landscapeProgressBar: {
          position: "absolute",
          bottom: 40 + insets.bottom,
          left: 16,
          right: 16,
          height: 44,
          justifyContent: "center",
          zIndex: 100,
        },
        prerenderIndicator: {
          position: "absolute",
          top: 50,
          left: 16,
          zIndex: 1000,
          backgroundColor: "rgba(0, 0, 0, 0.7)",
          paddingHorizontal: 12,
          paddingVertical: 6,
          borderRadius: 16,
        },
        prerenderText: {
          fontSize: 12,
          fontWeight: "bold",
        },
        touchOverlay: {
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: "transparent",
          zIndex: 1,
        },
      }),
    [insets.bottom],
  );

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>
          Network disconnected, please check and refresh
        </Text>
        <TouchableOpacity onPress={handleRetry} style={styles.retryButton}>
          <SvgIcon name="refresh" style={styles.refreshIcon} />
          <Text style={styles.retryButtonText}>Refresh</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.videoTouchable} onLayout={handleContainerLayout}>
        <PlayerViewComponent
          viewId={viewId}
          onLoad={() => {
            setCanInit(true);
            console.log("VideoPlayer: onLoad", playerIndex);
          }}
          style={styles.player}
        />

        {showPoster && (
          <View style={styles.coverContainer} pointerEvents="none">
            <Image
              source={{ uri: episode.cover_url }}
              contentFit={dramaVideoOrientation === 1 ? "contain" : "cover"}
              style={styles.coverImage}
            />
            <View style={styles.coverOverlay} />
          </View>
        )}

        <TouchableOpacity
          style={styles.touchOverlay}
          onPress={handleVideoPress}
          activeOpacity={1}
          delayPressIn={0}
          delayPressOut={0}
        />

        <PlaybackControls
          currentOrientation={currentOrientation}
          isPlaying={isPlaying}
          showPlayButton={!isPlaying}
          showLoading={showLoading}
          onPlayPause={handlePlayPause}
          onVideoPress={handleVideoPress}
          onFullscreenPress={handleFullscreenPress}
          currentLikeCount={currentLikeCount}
          isLiked={isLiked}
          currentCommentCount={0}
          isCommented={false}
          onLikePress={handleLandscapeLikePress}
          onCommentPress={handleCommentPress}
          playbackSpeed={playbackSpeed}
          onSpeedChange={onSpeedChange}
          playInfoList={playInfoList}
          currentQuality={currentQuality}
          onQualityChange={handleQualityChange}
          episodes={episodes}
          currentEpisodeIndex={currentEpisodeIndex || 0}
          dramaTitle={dramaTitle}
          dramaCoverUrl={dramaCoverUrl}
          dramaId={dramaId}
          onEpisodeSelect={onEpisodeSelect}
          fullscreenButtonPosition={getFullscreenButtonPosition()}
          dramaVideoOrientation={dramaVideoOrientation}
          isFeedTab={isFeedTab}
        />

        {/* Pre-render status indicator */}
        {/*<View style={styles.prerenderIndicator}>*/}
        {/*  <Text*/}
        {/*    style={[*/}
        {/*      styles.prerenderText,*/}
        {/*      { color: hitPreRender ? "#00ff00" : "#ff4444" },*/}
        {/*    ]}*/}
        {/*  >*/}
        {/*    {hitPreRender ? "✓ 命中预渲染" : "✗ 未命中预渲染"}*/}
        {/*  </Text>*/}
        {/*</View>*/}

        {!(duration < 60 && dramaVideoOrientation !== 1) && (
          <View
            style={
              currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP
                ? styles.bottomProgressBar
                : styles.landscapeProgressBar
            }
          >
            <SeekBar
              duration={duration}
              currentTime={currentTime}
              disabled={!isActive || !isScreenFocused || isRemotePlaybackActive() || !playerRef.current}
              onSeek={handleSeek}
              onSeekingChange={onSeekingChange}
            />
          </View>
        )}
      </View>
    </View>
  );
};

export default VideoPlayer;
