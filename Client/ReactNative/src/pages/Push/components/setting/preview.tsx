import React from 'react';
import {Icon, View} from '@ant-design/react-native';
import {StyleSheet, Text, TouchableWithoutFeedback} from 'react-native';
import {PushMode, uiConfig} from '@/store/push/ui';
import {
  VeLiveOrientation,
  VeLiveVideoCaptureType,
} from '@byteplus/react-native-live-push';
import {getPusher} from '@/store/push/pusher';
import {pushConfig} from '@/store/push/config';
import {useSnapshot} from 'valtio';
import Orientation from 'react-native-orientation-locker';

const styles = StyleSheet.create({
  setting: {
    width: '90%',
    marginHorizontal: '5%',
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'center',
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

const Preview = () => {
  const ui = useSnapshot(uiConfig);

  return (
    <>
      <View style={styles.setting}>
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
        {ui.mode !== PushMode.Audio && (
          <TouchableWithoutFeedback
            onPress={() => {
              if (
                ui.orientation === VeLiveOrientation.VeLiveOrientationLandscape
              ) {
                getPusher().setOrientation(
                  VeLiveOrientation.VeLiveOrientationPortrait,
                );
                uiConfig.orientation =
                  VeLiveOrientation.VeLiveOrientationPortrait;
                Orientation.lockToPortrait();
              } else {
                getPusher().setOrientation(
                  VeLiveOrientation.VeLiveOrientationLandscape,
                );
                uiConfig.orientation =
                  VeLiveOrientation.VeLiveOrientationLandscape;
                Orientation.lockToLandscape();
              }
            }}>
            <View style={styles.item}>
              <Icon
                style={styles.text}
                name={
                  ui.orientation ===
                  VeLiveOrientation.VeLiveOrientationLandscape
                    ? 'rotate-left'
                    : 'rotate-right'
                }
              />
              <Text style={styles.text}>Horizontal/vertical screen</Text>
            </View>
          </TouchableWithoutFeedback>
        )}
        <TouchableWithoutFeedback
          onPress={() => {
            uiConfig.showPreSetting = true;
          }}>
          <View style={styles.item}>
            <Icon style={styles.text} name="setting" />
            <Text style={styles.text}>Setting</Text>
          </View>
        </TouchableWithoutFeedback>
      </View>
    </>
  );
};

export default Preview;
