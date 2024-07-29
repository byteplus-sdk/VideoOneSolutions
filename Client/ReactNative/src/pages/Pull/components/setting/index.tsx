import React from 'react';
import {View} from '@ant-design/react-native';
import {StyleSheet} from 'react-native';
import AudioVideoSetting from './AudioVideoSetting';
import BaseSetting from './BaseSetting';

const styles = StyleSheet.create({
  setting: {
    position: 'absolute',
    bottom: 20,
    right: 12,
  },
});

const Setting = () => {
  return (
    <View style={styles.setting}>
      <BaseSetting />
      <AudioVideoSetting />
    </View>
  );
};

export default Setting;
