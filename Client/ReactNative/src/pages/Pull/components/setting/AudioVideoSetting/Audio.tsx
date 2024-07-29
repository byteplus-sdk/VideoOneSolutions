import {
  Checkbox,
  Flex,
  Slider,
  WhiteSpace,
  WingBlank,
} from '@ant-design/react-native';
import React from 'react';
import {StyleSheet, Text} from 'react-native';
import {useSnapshot} from 'valtio';
import {getPlayer, playerConfig} from '../../../../../store/pull/player';

const styles = StyleSheet.create({
  row: {
    gap: 16,
  },
});

const AudioSetting = () => {
  const {mute, volume} = useSnapshot(playerConfig);

  return (
    <WingBlank>
      <WhiteSpace />
      <Text>Volume</Text>
      <WhiteSpace />
      <Flex style={styles.row}>
        <Flex.Item>
          <Slider
            max={1}
            min={0}
            value={volume}
            onChange={(data = 1) => {
              playerConfig.volume = data;
              getPlayer()?.setPlayerVolume(data);
            }}
          />
        </Flex.Item>
        <Checkbox
          checked={mute}
          onChange={e => {
            playerConfig.mute = e.target.checked;
            getPlayer()?.setMute(e.target.checked);
          }}>
          Mute
        </Checkbox>
      </Flex>
      <WhiteSpace />
    </WingBlank>
  );
};

export default AudioSetting;
