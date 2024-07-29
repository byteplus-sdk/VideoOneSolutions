import React from 'react';
import {View} from '@ant-design/react-native';
import {StyleSheet} from 'react-native';
import InfoPanel from './InfoPanel';
import CallbackPanel from './CallbackPanel';
import {useSnapshot} from 'valtio';
import {playerConfig} from '../../../../store/pull/player';

const styles = StyleSheet.create({
  setting: {
    position: 'absolute',
    top: 20,
    left: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    borderRadius: 12,
    width: '80%',
  },
});

const Panel = () => {
  const {enableInfo, enableLogs} = useSnapshot(playerConfig);

  if (!enableInfo && !enableLogs) {
    return null;
  }

  return (
    <View style={styles.setting}>
      {enableInfo && <InfoPanel />}
      {enableLogs && <CallbackPanel />}
    </View>
  );
};

export default Panel;
