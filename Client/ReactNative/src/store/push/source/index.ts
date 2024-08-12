import {AudioSourceList, ExternalAudioSource} from './audio';
import {ExternalVideoSource, VideoSources} from './video';

let video: ExternalVideoSource | undefined;
export async function startPushExternalVideoFrame() {
  video?.stop();
  video = new ExternalVideoSource(VideoSources[0]);
  await video.start();
}

export function stopPushExternalVideoFrame() {
  video?.stop();
}

let audio: ExternalAudioSource | undefined;
export async function startPushExternalAudioFrame() {
  audio?.stop();
  audio = new ExternalAudioSource(AudioSourceList[0]);
  await audio.start();
}

export function stopPushExternalAudioFrame() {
  audio?.stop();
}
