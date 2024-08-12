import {
  VeLiveAudioCaptureType,
  VeLivePusherRenderMode,
  VeLiveVideoCaptureType,
  VeLiveVideoCodec,
  VeLiveVideoResolution,
} from '@byteplus/react-native-live-push';
import {proxy, subscribe} from 'valtio';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const pushConfig = proxy({
  /** Streaming address */
  url: '',
  /** Video capture resolution */
  videoResolution: VeLiveVideoResolution.VeLiveVideoResolution720P,
  /** Video encoding resolution */
  videoEncodeResolution: VeLiveVideoResolution.VeLiveVideoResolution720P,
  /** Video capture frame rate */
  videoFps: 15,
  /** Video encoding frame rate */
  videoEncodeFps: 15,
  /** Encoding format */
  videoEncodeType: VeLiveVideoCodec.VeLiveVideoCodecH264,
  /** Video encoding GOP */
  gop: 2,
  /** B-Frame */
  bFrame: false,
  /** Target bitrate */
  bitrate: 2588,
  /** Minimum bitrate */
  minBitrate: 1035,
  /** Maximum bitrate */
  maxBitrate: 4313,
  /** Preview fill mode */
  fillMode: VeLivePusherRenderMode.VeLivePusherRenderModeFill,
  /** Background mode */
  backgroundMode: false,
  /** Hard encoding */
  enableAccelerate: true,
  /** Background video capture type */
  backgroundCaptureType: VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
  /** Capture type */
  captureType: VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera,
  /** Audio capture type */
  audioCaptureType: VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone,
  /** Push image */
  image: null as any,
});

subscribe(pushConfig, ops => {
  for (let [_, path] of ops) {
    if (path.includes('bitrate')) {
      pushConfig.minBitrate = Math.round((pushConfig.bitrate * 2) / 5);
      pushConfig.maxBitrate = Math.round((pushConfig.bitrate * 5) / 3);
    }
    if (path.includes('url')) {
      AsyncStorage.setItem('pushConfig.url', pushConfig.url);
    }
  }
});

export const resetPushConfig = async () => {
  const url = (await AsyncStorage.getItem('pushConfig.url')) || '';
  pushConfig.url = url;
  pushConfig.videoResolution = VeLiveVideoResolution.VeLiveVideoResolution720P;
  pushConfig.videoEncodeResolution =
    VeLiveVideoResolution.VeLiveVideoResolution720P;
  pushConfig.videoFps = 15;
  pushConfig.videoEncodeFps = 15;
  pushConfig.videoEncodeType = VeLiveVideoCodec.VeLiveVideoCodecH264;
  pushConfig.gop = 2;
  pushConfig.bFrame = false;
  pushConfig.bitrate = 2588;
  pushConfig.fillMode = VeLivePusherRenderMode.VeLivePusherRenderModeFill;
  pushConfig.backgroundMode = false;
  pushConfig.enableAccelerate = true;
  pushConfig.backgroundCaptureType =
    VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame;
  pushConfig.captureType = VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera;
  pushConfig.audioCaptureType =
    VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone;
  pushConfig.image = null;
};

resetPushConfig();
