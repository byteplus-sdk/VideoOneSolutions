import {
  VeLiveOrientation,
  VeLiveVideoResolution,
} from '@byteplus/react-native-live-push';
import {uiConfig} from './ui';

/** Get the width and height through Resolution */
export function getResolutionSize(resolution: VeLiveVideoResolution) {
  let size = [1280, 720];
  switch (resolution) {
    case VeLiveVideoResolution.VeLiveVideoResolution1080P:
      size = [1920, 1080];
      break;
    case VeLiveVideoResolution.VeLiveVideoResolution720P:
      size = [1280, 720];
      break;
    case VeLiveVideoResolution.VeLiveVideoResolution540P:
      size = [960, 540];
      break;
    case VeLiveVideoResolution.VeLiveVideoResolution480P:
      size = [640, 480];
      break;
    case VeLiveVideoResolution.VeLiveVideoResolution360P:
      size = [480, 360];
      break;
    default:
      size = [1280, 720];
      break;
  }
  if (uiConfig.orientation === VeLiveOrientation.VeLiveOrientationLandscape) {
    return {
      width: size[0],
      height: size[1],
    };
  } else {
    return {
      width: size[1],
      height: size[0],
    };
  }
}
