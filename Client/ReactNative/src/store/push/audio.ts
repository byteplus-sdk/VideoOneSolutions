import {proxy} from 'valtio';

export const audioConfig = proxy({
  /** Audio frame callback */
  audioFrameCallback: false,
  /** Audio frame filter */
  audioFrameFilter: false,
  /** Live volume */
  volume: 1,
});

export const resetAudioConfig = () => {
  audioConfig.audioFrameCallback = false;
  audioConfig.audioFrameFilter = false;
  audioConfig.volume = 1;
};
