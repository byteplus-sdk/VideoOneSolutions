// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

/*
 * @author bytedance
 * @version 1.0
 * @date 2025/1/21
 */

export {
  // core player
  initPlayer,
  initEnv,
  TTVideoEngine,
  PlayerViewComponent,

  // video source
  createDirectUrlSource,
  createVidSource,
  createVideoModelSource,

  // player state and type
  PlaybackState,
  PlayerLoadState,
  FillModeType,

  // strategy
  setStrategySources,
  addStrategySources,
  enableEngineStrategy,
  StrategyType,
  StrategyScene,

  // pre-render
  getPreRenderEngine,
  getFirstFrameEngine,
  setPreRenderCallback,
  setView,

  // picture in picture
  isPictureInPictureSupported,
  isPictureInPictureStarted,
  setPictureInPictureListener,

  // audio session
  setActiveAudioSession,

  // debug tool
  setupLogger,
  LogLevel,
  showDebugTool,
  removeDebugTool,

  // cache management
  clearAllCaches,

  // device info
  getDeviceID,
  getEngineUniqueId,

  // resolution type
  ResolutionType,

  // pre-load task
  setDefaultPreloadTaskFeature,
  setPreloadTaskFactory,

  // permission request
  requestOverlayPermission,

  // type definition
  type VideoSource,
  type DirectUrlSourceInitProps,
  type InitPlayerOptions,
  type RotationType,
  type InitEnvOptions,
  type VidSourceInitProps,
  type ModelInfo,
  type ThumbInfoItem,
  type VideoModelSourceInitProps,
  type SubtitleInfoItem,
  type SubtitleInfo,
  type SubModelProvider,
} from "@byteplus/react-native-vod-player";
