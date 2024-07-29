import {proxy} from 'valtio';
import dayjs from 'dayjs';

export const infoConfig = proxy({
  enableInfo: false,
  enableLogs: false,
  info: '',
  logs: [] as {id: string; time: string; message: string}[],
  audioFrameCallbackCount: 0,
  videoFrameCallbackCount: 0,
  accumulatedAudioFrameCallbackCount: 0,
});

export const resetInfoConfig = () => {
  infoConfig.enableInfo = false;
  infoConfig.enableLogs = false;
  infoConfig.info = '';
  infoConfig.logs = [];
  infoConfig.audioFrameCallbackCount = 0;
  infoConfig.videoFrameCallbackCount = 0;
  infoConfig.accumulatedAudioFrameCallbackCount = 0;
};

export const addLog = (message: string) => {
  infoConfig.logs.unshift({
    id: Date.now().toString() + Math.random(),
    time: dayjs().format('HH:mm:ss'),
    message,
  });
};
