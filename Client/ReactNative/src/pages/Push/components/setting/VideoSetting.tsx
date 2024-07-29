import {WhiteSpace, InputItem, Picker, List} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {VeLiveVideoResolution} from '@byteplus/react-native-live-push';
import {ScrollView} from 'react-native';
import {getPusher} from '@/store/push/pusher';
import {getDefaultVideoEncoderConfiguration} from '@/store/push/api';
import {pushConfig} from '@/store/push/config';

const VideoSetting = () => {
  const push = useSnapshot(pushConfig);

  return (
    <ScrollView>
      <List>
        <Picker
          value={[push.videoEncodeResolution]}
          onChange={value => {
            pushConfig.videoEncodeResolution =
              value[0] as VeLiveVideoResolution;
            getPusher().setVideoEncoderConfiguration(
              getDefaultVideoEncoderConfiguration(),
            );
          }}
          data={[
            {
              label: '360P',
              value: VeLiveVideoResolution.VeLiveVideoResolution360P,
            },
            {
              label: '480P',
              value: VeLiveVideoResolution.VeLiveVideoResolution480P,
            },
            {
              label: '540P',
              value: VeLiveVideoResolution.VeLiveVideoResolution540P,
            },
            {
              label: '720P',
              value: VeLiveVideoResolution.VeLiveVideoResolution720P,
            },
            {
              label: '1080P',
              value: VeLiveVideoResolution.VeLiveVideoResolution1080P,
            },
          ]}>
          <List.Item>Video resolution</List.Item>
        </Picker>
        <Picker
          value={[push.videoEncodeFps]}
          onChange={value => {
            pushConfig.videoEncodeFps = value[0] as number;
            getPusher().setVideoEncoderConfiguration(
              getDefaultVideoEncoderConfiguration(),
            );
          }}
          data={[
            {label: '15', value: 15},
            {label: '20', value: 20},
            {label: '25', value: 25},
            {label: '30', value: 30},
          ]}>
          <List.Item>Video FPS</List.Item>
        </Picker>
        <InputItem
          placeholder="Video bitrate"
          defaultValue={push.bitrate.toString()}
          onChange={targetBitrate => {
            pushConfig.bitrate = Number(targetBitrate);
            getPusher().setVideoEncoderConfiguration(
              getDefaultVideoEncoderConfiguration(),
            );
          }}>
          Video bitrate
        </InputItem>
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default VideoSetting;
