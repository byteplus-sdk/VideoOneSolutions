import {
  VeLivePixelFormat,
  VeLivePusher,
  VeLiveVideoBufferType,
  VeLiveVideoFrame,
  VeLiveVideoRotation,
} from '@byteplus/react-native-live-push';
import {ExternalSource, type ExternalSourceConfig} from './base';
import {readFileAsStream} from './fs';
import {rgbaToArgb, rgbaToBgra} from './rgba';

export interface ExternalVideoSourceConfig extends ExternalSourceConfig {
  type: string;
  width: number;
  height: number;
  pixel_fmt: number;
  // dataSize: number
}

function computeDataSize(input: ExternalVideoSourceConfig) {
  const {width, height, pixel_fmt} = input;

  switch (pixel_fmt) {
    // I420
    case 1:
    // NV12
    case 2:
      return (width * height * 3) / 2;
    // RGBA
    case 5:
    // ARGB
    case 6:
    // BGRA
    case 7:
      return width * height * 4;
    default:
      console.warn(`pixel_fmt "${pixel_fmt}" not right!`);
      throw new Error('unknown pixel format');
  }
}

export const VideoSources: ExternalVideoSourceConfig[] = [
  {
    type: 'NV12',
    filename: 'video_640x360_25fps_nv21.yuv',
    url: 'https://vevos.tos-cn-beijing.volces.com/live/video_640x360_25fps_nv21.yuv',
    width: 640,
    height: 360,
    pixel_fmt: VeLivePixelFormat.VeLivePixelFormatI420,
  },
];

export class ExternalVideoSource extends ExternalSource<VeLiveVideoFrame> {
  constructor(public config: ExternalVideoSourceConfig) {
    super(config);
    this._fps = 15;
  }

  async buildStream() {
    const inputFilepath = this._filepath;
    const dataSize = computeDataSize(this.config);
    const stream = readFileAsStream(inputFilepath, dataSize);
    return stream;
  }

  /**
   *
   * @param {Uint8Array} data
   */
  buildFrame(data: Uint8Array) {
    const {width, height, pixel_fmt} = this.config;

    const frameData = {
      pixel_fmt: pixel_fmt,
      width: width,
      height: height,
      data: [] as Uint8Array[],
      buffer: undefined as unknown as Uint8Array,
      linesize: [] as number[],
      timestamp_ms: Date.now(),
    };

    // I420
    if (pixel_fmt === 1) {
      let size = width * height;
      let yData = data.subarray(0, size);
      let uData = data.subarray(size, size + (size >> 2));
      let vData = data.subarray(size + (size >> 2), size + (size >> 1));
      frameData.data = [yData, uData, vData];
      frameData.linesize = [width, width >> 1, width >> 1];
    } else if (pixel_fmt === 2) {
      // NV12
      let size = width * height;
      let yData = data.subarray(0, size);
      let uvData = data.subarray(size, size + (((width / 2) * height) / 2) * 2);
      frameData.data = [yData, uvData];
      frameData.buffer = data.subarray(
        0,
        size + (((width / 2) * height) / 2) * 2,
      );
      frameData.linesize = [width, width];
    } else if (pixel_fmt === 5) {
      // RGBA
      frameData.data = [data];
      frameData.linesize = [width * 4];
    } else if (pixel_fmt === 6) {
      // ARGB
      frameData.data = [rgbaToArgb(data)];
      frameData.linesize = [width * 4];
    } else if (pixel_fmt === 7) {
      // BGRA
      frameData.data = [rgbaToBgra(data)];
      frameData.linesize = [width * 4];
    }

    const frame = new VeLiveVideoFrame();
    frame.setBufferType(VeLiveVideoBufferType.VeLiveVideoBufferTypeByteArray);
    frame.setPixelFormat(frameData.pixel_fmt);
    frame.setRotation(VeLiveVideoRotation.VeLiveVideoRotation0);
    (frame as any)._instance.width = frameData.width;
    (frame as any)._instance.height = frameData.height;
    (frame as any)._instance.ptsUs = frameData.timestamp_ms;
    (frame as any)._instance.textureId = 0;
    (frame as any)._instance.data = frameData.buffer;
    return frame;
  }

  /**
   *
   * @param {any} frame
   */
  pushFrame(pusher: VeLivePusher, frame: VeLiveVideoFrame) {
    pusher.pushExternalVideoFrame(frame);
  }
}
