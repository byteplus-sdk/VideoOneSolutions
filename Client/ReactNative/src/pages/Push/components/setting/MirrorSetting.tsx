import {WhiteSpace, Picker, List, Switch} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {mirrorConfig} from '@/store/push/mirror';
import {VeLiveVideoMirrorType} from '@byteplus/react-native-live-push';
import {getPusher} from '@/store/push/pusher';
import {ScrollView} from 'react-native';

const MirrorSetting = () => {
  const mirror = useSnapshot(mirrorConfig);
  return (
    <ScrollView>
      <List>
        <List.Item
          extra={
            <Switch
              checked={mirror.enable}
              onChange={value => {
                mirrorConfig.enable = value;
                if (value) {
                  getPusher().setVideoMirror(mirror.mirror, value);
                } else {
                  getPusher().setVideoMirror(mirror.mirror, value);
                }
              }}
            />
          }>
          Enable
        </List.Item>
        {mirror.enable ? (
          <Picker
            value={[mirror.mirror]}
            onChange={value => {
              const lastMirror = mirrorConfig.mirror;
              mirrorConfig.mirror = value[0] as VeLiveVideoMirrorType;
              getPusher().setVideoMirror(lastMirror, false);
              getPusher().setVideoMirror(
                value[0] as VeLiveVideoMirrorType,
                true,
              );
            }}
            data={[
              {
                label: 'Capture',
                value: VeLiveVideoMirrorType.VeLiveVideoMirrorCapture,
              },
              {
                label: 'Preview',
                value: VeLiveVideoMirrorType.VeLiveVideoMirrorPreview,
              },
              {
                label: 'Push',
                value: VeLiveVideoMirrorType.VeLiveVideoMirrorPushStream,
              },
            ]}>
            <List.Item>Mirror</List.Item>
          </Picker>
        ) : (
          <></>
        )}
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default MirrorSetting;
