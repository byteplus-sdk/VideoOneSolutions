import {WhiteSpace, Slider, List, View} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {audioConfig} from '@/store/push/audio';
import {ScrollView} from 'react-native';
import {getPusher} from '@/store/push/pusher';

const AudioSetting = () => {
  const audio = useSnapshot(audioConfig);

  return (
    <ScrollView>
      <List>
        <List.Item
          extra={
            <View style={{width: 200}}>
              <Slider
                max={1}
                min={0}
                value={audio.volume}
                onChange={(data = 1) => {
                  audioConfig.volume = data;
                  getPusher().getAudioDevice().setVoiceLoudness(data);
                }}
              />
            </View>
          }>
          Live Volume
        </List.Item>
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default AudioSetting;
