import React from 'react';
import {Text, WhiteSpace} from '@ant-design/react-native';
import {ScrollView, StyleSheet} from 'react-native';
import {useSnapshot} from 'valtio';
import {infoConfig} from '@/store/push/info';

const styles = StyleSheet.create({
  wrap: {
    padding: 8,
    maxHeight: 140,
    color: '#fff',
  },
});

const InfoPanel = () => {
  const {info} = useSnapshot(infoConfig);

  return (
    <ScrollView style={styles.wrap}>
      <Text>Statics</Text>
      <Text>{info}</Text>
      <WhiteSpace />
    </ScrollView>
  );
};

export default InfoPanel;
