import {VeLiveVideoResolution} from '@byteplus/react-native-live-push';
import {proxy} from 'valtio';

export const recordConfig = proxy({
  /** Whether to record live broadcast */
  isRecord: false,
  /** Video resolution */
  videoResolution: VeLiveVideoResolution.VeLiveVideoResolution360P,
  /** Video encode FPS */
  videoEncodeFps: 15,
  /** Video bitrate */
  videoBitrate: 2000,
});

export const resetRecordConfig = () => {
  recordConfig.isRecord = false;
  recordConfig.videoResolution =
    VeLiveVideoResolution.VeLiveVideoResolution360P;
  recordConfig.videoEncodeFps = 15;
  recordConfig.videoBitrate = 2000;
};
