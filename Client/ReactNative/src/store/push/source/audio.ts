import {
  VeLiveAudioBufferType,
  VeLiveAudioFrame,
  type VeLivePusher,
} from '@byteplus/react-native-live-push';
import {ExternalSource, type ExternalSourceConfig} from './base';
import {readFileAsStream} from './fs';

export interface ExternalAudioSourceConfig extends ExternalSourceConfig {
  key: string;
  channel: number;
  channelValue: number;
  bytePerSample: number;
  sampleRate: number;
  sampleRateValue: number;
}

export const AudioSourceList: ExternalAudioSourceConfig[] = [
  {
    key: 'pcm',
    filename: 'audio_44100_16bit_2ch.pcm',
    url: 'https://vevos.tos-cn-beijing.volces.com/live/audio_44100_16bit_2ch.pcm',
    // channel: VeLiveAudioChannel.VeLiveAudioChannelStereo,
    channel: 1,
    channelValue: 2,
    // sample_rate: VeLiveAudioSampleRate.VeLiveAudioSampleRate44100,
    sampleRate: 3,
    sampleRateValue: 44100,
    bytePerSample: 2,
  },
];

export class ExternalAudioSource extends ExternalSource<VeLiveAudioFrame> {
  /**
   *
   * @param {typeof AudioSourceList[0]} config
   * @param {*} pusher
   */
  constructor(public config: ExternalAudioSourceConfig) {
    super(config);
    this._fps = 100;
  }

  get dataSize() {
    const {channelValue, bytePerSample, sampleRateValue} = this.config;
    const dataSize =
      sampleRateValue * (1 / this._fps) * channelValue * bytePerSample;
    return dataSize;
  }

  async buildStream() {
    const inputFilepath = this._filepath;
    const stream = await readFileAsStream(inputFilepath, this.dataSize);
    return stream;
  }

  buildFrame(data: Uint8Array) {
    const {channel, sampleRate} = this.config;
    const frameData = {
      bufferType: VeLiveAudioBufferType.VeLiveAudioBufferTypeByteBuffer,
      sampleRate: sampleRate,
      channel: channel,
      timestamp_ms: Date.now(),
      data: data,
    };

    const frame = new VeLiveAudioFrame();
    (frame as any)._instance.bufferType = frameData.bufferType;
    (frame as any)._instance.sampleRate = frameData.sampleRate;
    (frame as any)._instance.channels = frameData.channel;
    (frame as any)._instance.buffer = frameData.data;
    (frame as any)._instance.ptsUs = frameData.timestamp_ms;
    (frame as any)._instance.samplesPerChannel =
      data.length / this.config.channelValue / (16 / 8);

    return frame;
  }

  pushFrame(pusher: VeLivePusher, frame: VeLiveAudioFrame) {
    pusher.pushExternalAudioFrame(frame);
  }
}
