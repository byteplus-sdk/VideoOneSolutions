import React from 'react';
import {Text, WhiteSpace} from '@ant-design/react-native';
import {ScrollView, StyleSheet} from 'react-native';
import {useSnapshot} from 'valtio';
import {playerConfig} from '../../../../store/pull/player';

const styles = StyleSheet.create({
  wrap: {
    padding: 8,
    maxHeight: 140,
    color: '#fff',
  },
});

const InfoPanel = () => {
  const {info} = useSnapshot(playerConfig);

  return (
    <ScrollView style={styles.wrap}>
      <Text>Info</Text>
      <Text>{info}</Text>
      <WhiteSpace />
    </ScrollView>
  );
};

export default InfoPanel;
