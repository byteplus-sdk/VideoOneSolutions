import {proxy} from 'valtio';

import {
  VeLivePlayerFormat,
  VeLivePlayerProtocol,
  VeLivePlayerResolution,
} from '@byteplus/react-native-live-pull';

export const vePlayerResolutionList = [
  {
    value: VeLivePlayerResolution.VeLivePlayerResolutionOrigin,
    label: 'Origin',
    bitrate: 4000,
  },
  {
    value: VeLivePlayerResolution.VeLivePlayerResolutionUHD,
    label: 'UHD',
    bitrate: 3200,
  },
  {
    value: VeLivePlayerResolution.VeLivePlayerResolutionHD,
    label: 'HD',
    bitrate: 2048,
  },
  {
    value: VeLivePlayerResolution.VeLivePlayerResolutionSD,
    label: 'SD',
    bitrate: 1024,
  },
  {
    value: VeLivePlayerResolution.VeLivePlayerResolutionLD,
    label: 'LD',
    bitrate: 512,
  },
];

export const vePlayerResolutionMap = vePlayerResolutionList.reduce(
  (map, item) => {
    map[item.value] = item;
    return map;
  },
  {} as Record<
    string,
    {
      value: VeLivePlayerResolution;
      label: string;
      bitrate: number;
    }
  >,
);

export const pullConfig = proxy({
  /** Enable sei */
  sei: false,
  /** Enable abr */
  abr: false,
  /** Enable automatic switching of bitrate */
  enableSwitchAbr: false,
  /** Format type */
  format: VeLivePlayerFormat.VeLivePlayerFormatFLV,
  /** Protocol type */
  protocol: VeLivePlayerProtocol.VeLivePlayerProtocolTCP,
  /** Play address */
  url: '',
  /** Multiple Address */
  streams: [] as {
    url: string;
    resolution: number;
    bitrate: number;
  }[],
});
