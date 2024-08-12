import React, {useMemo} from 'react';
import {Text, WhiteSpace} from '@ant-design/react-native';
import {ScrollView, StyleSheet} from 'react-native';
import {useSnapshot} from 'valtio';
import {playerConfig} from '../../../../store/pull/player';

const styles = StyleSheet.create({
  wrap: {
    padding: 8,
    maxHeight: 140,
    color: '#fff',
    marginTop: 16,
  },
});

const CallbackPanel = () => {
  const {logs} = useSnapshot(playerConfig);

  const list = useMemo(() => {
    if (logs?.length > 0) {
      return logs.slice(0, 50);
    }
    return [];
  }, [logs]);

  return (
    <ScrollView style={styles.wrap}>
      <Text>Callback</Text>
      {list.map(item => {
        return (
          <Text key={item.id}>
            [{item.time}] {item.message}
          </Text>
        );
      })}
      <WhiteSpace />
    </ScrollView>
  );
};

export default CallbackPanel;
