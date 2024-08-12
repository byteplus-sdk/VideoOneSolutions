import {VeLiveVideoMirrorType} from '@byteplus/react-native-live-push';
import {proxy} from 'valtio';

export const mirrorConfig = proxy({
  /** Enable mirror */
  enable: false,
  /** mirror type */
  mirror: VeLiveVideoMirrorType.VeLiveVideoMirrorCapture,
});

export const resetMirrorConfig = () => {
  mirrorConfig.enable = false;
  mirrorConfig.mirror = VeLiveVideoMirrorType.VeLiveVideoMirrorCapture;
};
