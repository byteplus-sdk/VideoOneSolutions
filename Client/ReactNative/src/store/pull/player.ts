import {proxy} from 'valtio';
import {Platform} from 'react-native';

import {
  initEnv,
  initPlayer as _initPlayer,
  type InitOptions,
  VeLivePlayerMirror,
  VeLivePlayerResolution,
  VeLivePlayerStreamData,
  VeLivePlayerStream,
  VeLivePlayerStatus,
  VeLivePlayerFormat,
  VeLivePlayerProtocol,
  VeLivePlayer,
  VeLivePlayerRotation,
  VeLivePlayerFillMode,
} from '@byteplus/react-native-live-pull';

import {pullConfig} from './config';

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

export const playerConfig = proxy({
  current: {} as VeLivePlayer,
  rotation: VeLivePlayerRotation.VeLivePlayerRotation0,
  fillMode: VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit,
  mirror: VeLivePlayerMirror.VeLivePlayerMirrorNone,
  resolution: VeLivePlayerResolution.VeLivePlayerResolutionOrigin,
  enableSuperResolution: false,
  volume: 1,
  mute: false,
  background: false,
  mini: false,
  info: '',
  logs: [] as {id: string; time: string; message: string}[],
  enableInfo: true,
  enableLogs: true,
});

let _player: VeLivePlayer;

export const getPlayer = () => {
  return _player;
};

export const initPlayer = async (options: InitOptions) => {
  _player = await _initPlayer(options);
  // Enable super resolution
  if (Platform.OS === 'ios') {
    _player.setProperty('VeLivePlayerKeySetReportKernelLogEnable', 1);
    _player.setProperty('VeLivePlayerKeySetParamsBMF', {
      NNSR: {
        EnableUseBMFConfig: 1,
        UseBMF: 1,
        Enabled: 1,
        StrategyConfig: {
          strategy_360_1080: {
            BmfAlgorithType: 5,
            BmfScaleType: 5,
            FpsLimit: '0_30',
            ResolutionLimit: '360_640_1080_1920',
            UseSoft: 0,
          },
        },
      },
    });
  }
  const streamData = new VeLivePlayerStreamData();
  if (pullConfig.abr) {
    const mainStreamList = [];
    for (let item of pullConfig.streams) {
      const stream = new VeLivePlayerStream();
      stream.url = item.url;
      stream.bitrate = item.bitrate;
      stream.resolution = item.resolution;
      mainStreamList.push(stream);
    }

    streamData.mainStreamList = mainStreamList;
    streamData.enableABR = pullConfig.enableSwitchAbr;
    streamData.defaultProtocol = pullConfig.protocol;
    // Default play high-definition stream
    streamData.defaultResolution = pullConfig.streams.sort(
      (a, b) => a.resolution - b.resolution,
    )[0].resolution;
    _player.setPlayStreamData(streamData);
  } else {
    const stream = new VeLivePlayerStream();
    stream.url = pullConfig.url;
    stream.format = pullConfig.format;
    streamData.mainStreamList = [stream];
    streamData.enableABR = false;
    streamData.defaultFormat = pullConfig.format;
    streamData.defaultProtocol = pullConfig.protocol;
  }
  _player.setPlayStreamData(streamData);
  _player.play();

  playerConfig.info = '';
  playerConfig.logs = [];
  playerConfig.fillMode = VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit;
  playerConfig.mirror = VeLivePlayerMirror.VeLivePlayerMirrorNone;
  playerConfig.rotation = VeLivePlayerRotation.VeLivePlayerRotation0;
  playerConfig.resolution = VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
  playerConfig.volume = 1;
  playerConfig.mute = false;

  _player.setObserver({
    onFirstVideoFrameRender() {
      addLog('Video first frame rendered');
    },
    onFirstAudioFrameRender() {
      addLog('Audio first frame rendered');
    },
    onVideoRenderStall() {
      addLog('Video rendering lags');
    },
    onAudioRenderStall() {
      addLog('Audio rendering lags');
    },
    onResolutionSwitch(_player, resolution) {
      if (resolution !== playerConfig.resolution) {
        playerConfig.resolution = resolution;
      }
      addLog(`Resolution switch: ${VeLivePlayerResolution[resolution]}`);
    },
    onVideoSizeChanged(_player, width, height) {
      addLog(`Resolution switch: ${width} * ${height}`);
    },
    onReceiveSeiMessage(_player, message) {
      if (message.includes('[RTS]')) {
        return;
      }
      addLog(`Received sei message: ${message}`);
    },
    onMainBackupSwitch(_player, _streamType, _error) {
      addLog('Main backup switch');
    },
    onPlayerStatusUpdate(_player, status) {
      addLog('Player status update' + VeLivePlayerStatus[status]);
    },
    onSnapshotComplete(_player, _bitmap) {
      addLog('Snapshot completed');
    },
    onStreamFailedOpenSuperResolution(_player, err) {
      addLog(
        `Failed to open super resolution (${err.errorCode || ''}) ${err.errorMsg || ''}`,
      );
    },
    onStatistics(_player, info) {
      playerConfig.info = `url: ${info.url}
Current playback delay: ${info.delayMs}
Current download bitrate: ${info.bitrate}
Current playback format: ${VeLivePlayerFormat[info.format]}
Current frame rate: ${info.fps}
Resolution: ${info.width} * ${info.height}
Decoding mode: ${info.isHardwareDecode ? 'Hardware decoding' : 'Software decoding'}
Transport protocol: ${VeLivePlayerProtocol[info.protocol]}
Cumulative stutter duration: ${info.stallTimeMs}
Audio buffer size: ${info.audioBufferMs}
Video buffer size: ${info.videoBufferMs}
Video encoding type: ${info.videoCodec}`;
    },
    onError(_player, error) {
      if (error.errorCode === -999) {
        getPlayer().stop();
        setTimeout(() => {
          getPlayer().play();
        }, 200);
      }
      addLog(`Playback Error: (${error.errorCode}) ${error.errorMsg}`);
    },
  });

  return _player;
};

const addLog = (message: string) => {
  playerConfig.logs.unshift({
    id: Date.now().toString() + Math.random(),
    time: new Date().toLocaleString(),
    message,
  });
};
