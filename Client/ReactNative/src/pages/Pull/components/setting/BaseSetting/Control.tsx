import {
  Button,
  Checkbox,
  Flex,
  WhiteSpace,
  WingBlank,
} from '@ant-design/react-native';
import React from 'react';
import {StyleSheet, Text} from 'react-native';
import {getPlayer, playerConfig} from '../../../../../store/pull/player';
import {useSnapshot} from 'valtio';

const styles = StyleSheet.create({
  row: {
    gap: 16,
  },
});

const ControlSetting = () => {
  const {background} = useSnapshot(playerConfig);

  return (
    <WingBlank>
      <WhiteSpace />
      <Text>Control</Text>
      <WhiteSpace />
      <Flex style={styles.row}>
        <Flex.Item>
          <Button
            size="small"
            onPress={() => {
              getPlayer()?.play();
            }}>
            Play
          </Button>
        </Flex.Item>
        <Flex.Item>
          <Button
            size="small"
            onPress={() => {
              getPlayer()?.stop();
            }}>
            Stop
          </Button>
        </Flex.Item>
        <Flex.Item>
          <Button
            size="small"
            onPress={() => {
              const isPlaying = getPlayer()?.isPlaying();
              if (isPlaying) {
                getPlayer()?.pause();
              } else {
                getPlayer()?.play();
              }
            }}>
            Pause/Resume
          </Button>
        </Flex.Item>
      </Flex>
      <WhiteSpace />
      <Text>Playback</Text>
      <WhiteSpace />
      <Checkbox
        checked={background}
        onChange={e => {
          playerConfig.background = e.target.checked;
        }}>
        Background
      </Checkbox>
      <WhiteSpace />
    </WingBlank>
  );
};

export default ControlSetting;
