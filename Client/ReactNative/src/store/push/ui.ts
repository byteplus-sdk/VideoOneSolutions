import {VeLiveOrientation} from '@byteplus/react-native-live-push';
import {proxy} from 'valtio';

export enum PushMode {
  /** Video */
  Video = 1,
  /** Audio */
  Audio = 2,
  /** Screen */
  Screen = 3,
  /** File */
  File = 4,
}

export const uiConfig = proxy({
  /** Push mode */
  mode: PushMode.Video,
  /** Mute */
  mute: false,
  /** Horizontal and vertical screen */
  orientation: VeLiveOrientation.VeLiveOrientationPortrait,
  /** Playback state */
  pushState: false,
  /** Show push before setting */
  showPreSetting: false,
  /** Show push setting */
  showPushSetting: false,
  /** Show information panel */
  showInfoPanel: false,
  /** Screen sharing permission */
  screenPermission: false,
  /** Whether to show video capture view */
  showVideoCaptureView: true,
});

export const resetUIConfig = () => {
  uiConfig.mode = PushMode.Video;
  uiConfig.mute = false;
  uiConfig.orientation = VeLiveOrientation.VeLiveOrientationPortrait;
  uiConfig.pushState = false;
  uiConfig.showPreSetting = false;
  uiConfig.showPushSetting = false;
  uiConfig.showInfoPanel = false;
  uiConfig.screenPermission = false;
  uiConfig.showVideoCaptureView = true;
};
