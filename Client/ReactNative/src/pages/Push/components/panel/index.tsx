import React from 'react';
import {View} from '@ant-design/react-native';
import {StyleSheet} from 'react-native';
import InfoPanel from './InfoPanel';
import CallbackPanel from './CallbackPanel';
import {useSnapshot} from 'valtio';
import {infoConfig} from '@/store/push/info';

const styles = StyleSheet.create({
  setting: {
    position: 'absolute',
    top: 50,
    left: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    borderRadius: 12,
    width: '80%',
  },
});

const Panel = () => {
  const {enableInfo, enableLogs} = useSnapshot(infoConfig);

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
