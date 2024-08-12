import {
  VeLiveFileRecorderConfiguration,
  VeLiveVideoEncoderConfiguration,
} from '@byteplus/react-native-live-push';
import {pushConfig} from './config';
import {recordConfig} from './record';
import {getResolutionSize} from './utils';

/** Video Encoder */
export function getDefaultVideoEncoderConfiguration() {
  const videoEncoderConfig =
    new VeLiveVideoEncoderConfiguration().initWithResolution(
      pushConfig.videoEncodeResolution,
    );
  videoEncoderConfig.setCodec(pushConfig.videoEncodeType);
  videoEncoderConfig.setBitrate(pushConfig.bitrate);
  videoEncoderConfig.setMinBitrate(
    Math.min(pushConfig.minBitrate, pushConfig.bitrate),
  );
  videoEncoderConfig.setMaxBitrate(
    Math.max(pushConfig.maxBitrate, pushConfig.bitrate),
  );
  videoEncoderConfig.setGopSize(pushConfig.gop);
  videoEncoderConfig.setFps(pushConfig.videoEncodeFps);
  videoEncoderConfig.setEnableBFrame(pushConfig.bFrame);
  videoEncoderConfig.setEnableAccelerate(pushConfig.enableAccelerate);
  return videoEncoderConfig;
}

/** Record config */
export function getDefaultFileRecorderConfiguration() {
  const defaultRecordConfig = new VeLiveFileRecorderConfiguration();
  const {width, height} = getResolutionSize(recordConfig.videoResolution);
  defaultRecordConfig.setWidth(width);
  defaultRecordConfig.setHeight(height);
  defaultRecordConfig.setBitrate(recordConfig.videoBitrate);
  defaultRecordConfig.setFps(recordConfig.videoEncodeFps);
  return defaultRecordConfig;
}
