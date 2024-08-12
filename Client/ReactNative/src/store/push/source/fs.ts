import RNFS from 'react-native-fs';
import {Base64} from 'js-base64';

export const FILE_YUY = {
  filepath: '/video_640x360_25fps_nv21.yuv',
  url: 'https://vevos.tos-cn-beijing.volces.com/live/video_640x360_25fps_nv21.yuv',
};

export const FILE_PCM = {
  filepath: '/audio_44100_16bit_2ch.pcm',
  url: 'https://vevos.tos-cn-beijing.volces.com/live/audio_44100_16bit_2ch.pcm',
};

export function toAbsFilepath(filepath: string) {
  const absFile = RNFS.CachesDirectoryPath + filepath;
  return absFile;
}

export {RNFS};

export async function ensureFile(filepath: string, url: string) {
  if (await RNFS.exists(filepath).catch(() => false)) {
    return;
  }
  const job = RNFS.downloadFile({
    fromUrl: url,
    toFile: filepath,
  });
  await job.promise;
}

/**
 *
 * @param {string} filepath
 * @param {number} dataSize
 */
export async function readFileAsStream(filepath: string, dataSize: number) {
  const fileStat = await RNFS.stat(filepath);
  const totalSize = fileStat.size;

  let position = 0;
  const readNextFrameData = async () => {
    let base64String = await RNFS.read(filepath, dataSize, position, 'base64');
    let byte = Base64.toUint8Array(base64String);
    let bytesRead = byte.length;

    position += bytesRead;

    // If the end of the file is reached or exceeded, restart from the beginning
    if (position >= totalSize) {
      position = 0;
    }

    return byte;
  };

  return {
    readNext: readNextFrameData,
  };
}

export interface ReadStream {
  readNext(): Promise<Uint8Array>;
}
