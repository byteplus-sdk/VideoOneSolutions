import React, {useState} from 'react';
import {Modal, Tabs, View} from '@ant-design/react-native';
import {StyleSheet, Text, TouchableOpacity} from 'react-native';
import ControlSetting from './Control';
import InfoSetting from './Info';

const styles = StyleSheet.create({
  setting: {
    width: 64,
    backgroundColor: '#fff',
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
});

const BaseSetting = () => {
  const [visible, setVisible] = useState(false);

  const tabs = [{title: 'Control'}, {title: 'Info'}];

  return (
    <View style={styles.setting}>
      <TouchableOpacity
        onPress={() => {
          setVisible(true);
        }}>
        <Text>Setting</Text>
      </TouchableOpacity>
      <Modal
        maskClosable
        popup
        animationType="slide-up"
        visible={visible}
        onClose={() => {
          setVisible(false);
        }}>
        <Tabs tabs={tabs}>
          <ControlSetting />
          <InfoSetting />
        </Tabs>
      </Modal>
    </View>
  );
};

export default BaseSetting;
