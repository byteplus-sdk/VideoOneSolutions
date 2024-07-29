import {
  initEnv,
  type VeLivePusher,
  initPusher as _initPusher,
  relaunchPusher as _relaunchPusher,
  type InitOptions,
  VeLiveFirstFrameType,
  VeLivePusherStatus,
  VeLiveAudioPowerLevel,
  VeLiveNetworkQuality,
} from '@byteplus/react-native-live-push';
import {Platform} from 'react-native';
import {pushConfig, resetPushConfig} from './config';
import {getDefaultVideoEncoderConfiguration} from './api';
import {getResolutionSize} from './utils';
import {resetUIConfig, uiConfig} from './ui';
import {addLog, infoConfig, resetInfoConfig} from './info';
import {resetMirrorConfig} from './mirror';
import {resetAccompanimentConfig} from './accompaniment';
import {resetAudioConfig} from './audio';
import {resetRecordConfig} from './record';
import {resetVideoConfig} from './video';

initEnv({
  AppID: '605570',
  AppName: 'com.videoarvolc.live.rn',
  AppChannel: Platform.select({
    android: 'GoogleStore',
    ios: 'AppStore',
    default: '',
  }),
  AppVersion: '1.0.0',
  LicenseUri: {
    android: 'assets:///ttsdk.lic',
    ios: 'ttsdk.lic',
  },
  UserUniqueID: 'VeLiveQuickStartDemo',
});

let pusher!: VeLivePusher;
let cachedOptions: InitOptions;

export function getPusher() {
  return pusher;
}

async function createPusher(options: InitOptions) {
  cachedOptions = options;
  const size = getResolutionSize(pushConfig.videoResolution);
  const fps = pushConfig.videoFps;

  return _initPusher({
    ...options,
    videoConfig: {
      width: size.width,
      height: size.height,
      fps,
    },
  });
}

async function addListener() {
  pusher.setObserver({
    onError(code, subCode, msg) {
      addLog(`Player Error: ${code} ${subCode} ${msg}`);
    },
    onFirstVideoFrame(type) {
      switch (type) {
        case VeLiveFirstFrameType.VeLiveFirstCaptureFrame:
          addLog('The first frame of video acquisition is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstRenderFrame:
          addLog('The first frame of video rendering is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstEncodedFrame:
          addLog('The first frame of video encoding is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstSendFrame:
          addLog('The first frame of video sending is completed');
          break;
      }
    },
    onCameraOpened(open) {
      addLog(`Camera open status: ${open}`);
    },
    onMicrophoneOpened(open) {
      addLog(`Camera open status: ${open}`);
    },
    onStatusChange(status) {
      switch (status) {
        case VeLivePusherStatus.VeLivePushStatusNone:
          addLog('Initial status');
          break;
        case VeLivePusherStatus.VeLivePushStatusConnecting:
          addLog('Connecting to server');
          break;
        case VeLivePusherStatus.VeLivePushStatusConnectSuccess:
          addLog('Successfully connected to the server');
          break;
        case VeLivePusherStatus.VeLivePushStatusReconnecting:
          addLog('Reconnecting to the server');
          break;
        case VeLivePusherStatus.VeLivePushStatusConnectStop:
          addLog('The push stream connection is terminated');
          break;
        case VeLivePusherStatus.VeLivePushStatusConnectError:
          addLog('The push stream connection fails');
          break;
        case VeLivePusherStatus.VeLivePushStatusDisconnected:
          addLog('Disconnect from the server');
          break;
        default:
          break;
      }
    },
    android_onScreenRecording(open) {
      if (open) {
        addLog('Start screen recording');
      } else {
        addLog('End screen recording');
      }
    },
    onAudioPowerQuality(level, value) {
      switch (level) {
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelSilent:
          addLog(`Volume Level: Silence, volume: ${value}`);
          break;
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelQuiet:
          addLog(`Volume Level: Quiet, volume: ${value}`);
          break;
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelLight:
          addLog(`Volume Level: Light, volume: ${value}`);
          break;
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelNormal:
          addLog(`Volume Level: Normal, volume: ${value}`);
          break;
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelLoud:
          addLog(`Volume Level: Loud, volume: ${value}`);
          break;
        case VeLiveAudioPowerLevel.VeLiveAudioPowerLevelNoise:
          addLog(`Volume Level: Noisy, volume: ${value}`);
          break;
      }
    },
    onFirstAudioFrame(type) {
      switch (type) {
        case VeLiveFirstFrameType.VeLiveFirstCaptureFrame:
          addLog('The first frame of audio acquisition is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstRenderFrame:
          addLog('The first frame of audio rendering is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstEncodedFrame:
          addLog('The first frame of audio encoding is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstSendFrame:
          addLog('The first frame of audio sending is completed');
          break;
        case VeLiveFirstFrameType.VeLiveFirstAppAudioCaptureFrame:
          addLog(
            'The first frame of application audio acquisition is completed',
          );
          break;
      }
    },
    onNetworkQuality(quality) {
      switch (quality) {
        case VeLiveNetworkQuality.VeLiveNetworkQualityBad:
          addLog('Network quality: network quality poor');
          break;
        case VeLiveNetworkQuality.VeLiveNetworkQualityPoor:
          addLog('Network quality: network quality very poor');
          break;
        case VeLiveNetworkQuality.VeLiveNetworkQualityGood:
          addLog('Network quality: network quality good');
          break;
        case VeLiveNetworkQuality.VeLiveNetworkQualityUnknown:
          addLog('Network quality: network quality unknown');
          break;
      }
    },
  });

  pusher.setStatisticsObserver(
    {
      onLogMonitor(logInfo) {
        addLog(`logInfo: ${JSON.stringify(logInfo)}`);
      },
      onStatistics(info) {
        infoConfig.info = `Push address: ${info.url}
Maximum video bitrate: ${info.maxVideoBitrate}
Minimum video bitrate: ${info.minVideoBitrate}
Initial video bitrate: ${info.videoBitrate}
Capture resolution: ${info.captureWidth}, ${info.captureHeight}
Streaming resolution: ${info.encodeWidth}, ${info.encodeHeight}
Capture frame rate: ${info.captureFps}
Encoding frame rate: ${info.encodeFps}
Streaming frame rate: ${info.fps}
Video encoding bitrate: ${info.encodeVideoBitrate}
Audio encoding bitrate: ${info.encodeAudioBitrate}
Real-time bitrate: ${info.transportVideoBitrate}`;
      },
    },
    2,
  );
}

function startCapture() {
  pusher.startVideoCapture(pushConfig.captureType);
  pusher.startAudioCapture(pushConfig.audioCaptureType);
}

export async function initPusher(options: InitOptions) {
  pusher = await createPusher(options);
  addListener();
  startCapture();
  return pusher;
}

export async function relaunchPusher() {
  pusher.stopVideoCapture();
  pusher.stopAudioCapture();
  pusher.destroy();

  if (Platform.OS === 'ios') {
    uiConfig.showVideoCaptureView = false;
    setTimeout(() => {
      uiConfig.showVideoCaptureView = true;
    }, 0);
    return;
  }

  const size = getResolutionSize(pushConfig.videoResolution);
  const fps = pushConfig.videoFps;

  pusher = await _relaunchPusher({
    ...cachedOptions,
    videoConfig: {
      width: size.width,
      height: size.height,
      fps: fps,
    },
  });
  addListener();
  startCapture();
}

export async function startPush() {
  const videoEncoderConfiguration = getDefaultVideoEncoderConfiguration();

  pusher.setVideoEncoderConfiguration(videoEncoderConfiguration);

  pusher.startPush(pushConfig.url);
}

export function resetConfig() {
  resetUIConfig();
  resetPushConfig();
  resetInfoConfig();
  resetMirrorConfig();
  resetAccompanimentConfig();
  resetAudioConfig();
  resetRecordConfig();
  resetVideoConfig();
}
