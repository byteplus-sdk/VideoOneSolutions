import {getPusher} from '@/store/push/pusher';
import {WhiteSpace, InputItem, Button, List} from '@ant-design/react-native';
import React, {useState} from 'react';
import {ScrollView} from 'react-native';

const SeiSetting = () => {
  const [sei, setSei] = useState('');

  return (
    <ScrollView>
      <List>
        <InputItem
          onChange={value => {
            setSei(value);
          }}
          extra={
            <Button
              onPress={() => {
                if (!sei) {
                  return;
                }
                getPusher().sendSeiMessage(
                  'sei',
                  {
                    message: sei,
                  },
                  1,
                  true,
                  true,
                );
              }}>
              Send
            </Button>
          }>
          Info
        </InputItem>
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default SeiSetting;
