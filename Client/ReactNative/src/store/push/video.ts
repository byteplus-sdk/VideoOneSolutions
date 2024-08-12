import {proxy} from 'valtio';

export const videoConfig = proxy({
  /** Video Noise Reduction */
  videoNoiseReduction: false,
  /** Video Frame Callback */
  videoFrameCallback: false,
  /** Video Frame Filter */
  videoFrameFilter: false,
  /** Video Resolution */
  videoResolution: 0,
  /** Video Encode Fps */
  videoEncodeFps: 15,
  /** Video Bitrate */
  videoBitrate: 2000,
});

export const resetVideoConfig = () => {
  videoConfig.videoNoiseReduction = false;
  videoConfig.videoFrameCallback = false;
  videoConfig.videoFrameFilter = false;
  videoConfig.videoResolution = 0;
  videoConfig.videoEncodeFps = 15;
  videoConfig.videoBitrate = 2000;
};
