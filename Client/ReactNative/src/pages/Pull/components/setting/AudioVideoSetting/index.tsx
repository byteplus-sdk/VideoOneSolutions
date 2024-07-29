import React, {useState} from 'react';
import {Modal, Tabs, View} from '@ant-design/react-native';
import {StyleSheet, Text, TouchableOpacity} from 'react-native';
import VideoSetting from './Video';
import AudioSetting from './Audio';

const styles = StyleSheet.create({
  setting: {
    width: 64,
    backgroundColor: '#fff',
    paddingHorizontal: 8,
    paddingVertical: 2,
    marginTop: 8,
    textAlign: 'center',
  },
});

const BaseSetting = () => {
  const [visible, setVisible] = useState(false);

  const tabs = [{title: 'Video'}, {title: 'Audio'}];

  return (
    <View style={styles.setting}>
      <TouchableOpacity
        onPress={() => {
          setVisible(true);
        }}>
        <Text>Video</Text>
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
          <VideoSetting />
          <AudioSetting />
        </Tabs>
      </Modal>
    </View>
  );
};

export default BaseSetting;
