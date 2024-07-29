import {infoConfig} from '@/store/push/info';
import {List, WhiteSpace, Switch} from '@ant-design/react-native';
import React from 'react';
import {ScrollView} from 'react-native';
import {useSnapshot} from 'valtio';

const InfoSetting = () => {
  const {enableInfo, enableLogs} = useSnapshot(infoConfig);
  return (
    <ScrollView>
      <List>
        <List.Item
          extra={
            <Switch
              checked={enableInfo}
              onChange={value => {
                infoConfig.enableInfo = value;
              }}
            />
          }>
          Statics
        </List.Item>
        <List.Item
          extra={
            <Switch
              checked={enableLogs}
              onChange={value => {
                infoConfig.enableLogs = value;
              }}
            />
          }>
          Info
        </List.Item>
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default InfoSetting;
