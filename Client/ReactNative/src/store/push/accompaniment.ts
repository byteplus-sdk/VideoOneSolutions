import {proxy} from 'valtio';

export const accompanimentConfig = proxy({
  /** Enable accompaniment */
  enable: false,
  /** Accompaniment playback status */
  playStatus: false,
  /** Mix to the live stream */
  mixToLive: false,
  /** Subscribe callback */
  subscribeCallback: false,
  /** Accompaniment volume */
  volume: 1,
  /** Music progress */
  progress: 0,
});

export const resetAccompanimentConfig = () => {
  accompanimentConfig.enable = false;
  accompanimentConfig.playStatus = false;
  accompanimentConfig.mixToLive = false;
  accompanimentConfig.subscribeCallback = false;
  accompanimentConfig.volume = 1;
  accompanimentConfig.progress = 0;
};
