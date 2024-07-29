import React from 'react';
import {Icon, View} from '@ant-design/react-native';
import {StyleSheet, Text, TouchableWithoutFeedback} from 'react-native';
import {PushMode, uiConfig} from '@/store/push/ui';
import {getPusher} from '@/store/push/pusher';
import {VeLiveVideoCaptureType} from '@byteplus/react-native-live-push';
import {pushConfig} from '@/store/push/config';
import {useSnapshot} from 'valtio';

const styles = StyleSheet.create({
  setting: {
    display: 'flex',
    alignItems: 'center',
    gap: 16,
  },
  item: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#fff',
    gap: 4,
  },
  text: {
    color: '#fff',
  },
});

const Push = () => {
  const ui = useSnapshot(uiConfig);

  return (
    <View style={styles.setting}>
      {[PushMode.Video, PushMode.Audio].includes(ui.mode) && (
        <TouchableWithoutFeedback
          onPress={() => {
            getPusher().setMute(!uiConfig.mute);
            uiConfig.mute = !uiConfig.mute;
          }}>
          <View style={styles.item}>
            <Icon
              style={styles.text}
              name={ui.mute ? 'audio-muted' : 'audio'}
            />
            <Text style={styles.text}>Microphone</Text>
          </View>
        </TouchableWithoutFeedback>
      )}
      {ui.mode === PushMode.Video && (
        <TouchableWithoutFeedback
          onPress={() => {
            if (
              pushConfig.captureType ===
              VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera
            ) {
              getPusher().switchVideoCapture(
                VeLiveVideoCaptureType.VeLiveVideoCaptureBackCamera,
              );
              pushConfig.captureType =
                VeLiveVideoCaptureType.VeLiveVideoCaptureBackCamera;
            } else {
              getPusher().switchVideoCapture(
                VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera,
              );
              pushConfig.captureType =
                VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera;
            }
          }}>
          <View style={styles.item}>
            <Icon style={styles.text} name="interaction" />
            <Text style={styles.text}>Flip</Text>
          </View>
        </TouchableWithoutFeedback>
      )}
      <TouchableWithoutFeedback
        onPress={() => {
          uiConfig.showPushSetting = true;
        }}>
        <View style={styles.item}>
          <Icon style={styles.text} name="setting" />
          <Text style={styles.text}>Setting</Text>
        </View>
      </TouchableWithoutFeedback>
      <TouchableWithoutFeedback
        onPress={() => {
          uiConfig.showInfoPanel = true;
        }}>
        <View style={styles.item}>
          <Icon style={styles.text} name="info-circle" />
          <Text style={styles.text}>Info</Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  );
};

export default Push;
