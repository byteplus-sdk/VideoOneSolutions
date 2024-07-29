import React, {useEffect, useMemo, useRef} from 'react';
import {Button, Icon} from '@ant-design/react-native';
import type {RootStackParamList} from '../type';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import {
  AppState,
  DeviceEventEmitter,
  Image,
  Platform,
  StyleSheet,
  Text,
  TouchableWithoutFeedback,
  View,
} from 'react-native';
import Setting from './components/setting';
import Orientation from 'react-native-orientation-locker';
import {useSnapshot} from 'valtio';
import {PushMode, uiConfig} from '@/store/push/ui';
import {pushConfig} from '@/store/push/config';
import {
  NativeViewComponent,
  startScreenCapture,
  VeLiveAudioCaptureType,
  VeLiveVideoCaptureType,
} from '@byteplus/react-native-live-push';
import {
  getPusher,
  initPusher,
  relaunchPusher,
  resetConfig,
  startPush,
} from '@/store/push/pusher';
import {
  useCameraPermission,
  useMicrophonePermission,
} from 'react-native-vision-camera';
import {toggleBackground} from '@/notify';
import Panel from './components/panel';
import {
  startPushExternalAudioFrame,
  startPushExternalVideoFrame,
  stopPushExternalAudioFrame,
  stopPushExternalVideoFrame,
} from '@/store/push/source/index';
import RNFS from 'react-native-fs';

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
  },
  btnWrap: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-around',
    borderRadius: 16,
    position: 'absolute',
    width: '80%',
    left: '10%',
    top: 30,
  },
  close: {
    position: 'absolute',
    left: 12,
    color: '#fff',
    top: 12,
  },
  btn: {
    borderRadius: 16,
    paddingVertical: 4,
    paddingHorizontal: 12,
  },
  startBtn: {
    position: 'absolute',
    bottom: 20,
    width: '90%',
    height: 44,
    opacity: 1,
    borderRadius: 22,
    marginHorizontal: '5%',
  },
});

const list = [
  {
    label: 'Camera',
    value: PushMode.Video,
  },
  {
    label: 'Microphone',
    value: PushMode.Audio,
  },
  ...(Platform.OS === 'android'
    ? [
        {
          label: 'Screen',
          value: PushMode.Screen,
        },
      ]
    : []),
];
const viewId = 'live-pusher';

const Push = ({
  navigation,
}: NativeStackScreenProps<RootStackParamList, 'Push'>) => {
  const {
    hasPermission: hasCameraPermission,
    requestPermission: requestCameraPermission,
  } = useCameraPermission();
  const {
    hasPermission: hasMicrophonePermission,
    requestPermission: requestMicrophonePermission,
  } = useMicrophonePermission();
  const ui = useSnapshot(uiConfig);
  const push = useSnapshot(pushConfig);
  const pusherRef = useRef(null);
  /** Start live push */
  const start = () => {
    startPush();
    uiConfig.pushState = true;
  };

  const showStartBtn = useMemo(() => {
    if (ui.pushState) {
      return false;
    }
    if (ui.mode === PushMode.Screen && !ui.screenPermission) {
      return false;
    }
    return true;
  }, [ui]);

  useEffect(() => {
    Orientation.lockToPortrait();
    return () => {
      resetConfig();
      Orientation.lockToPortrait();
    };
  }, []);

  const onViewLoad = async () => {
    try {
      if (!hasCameraPermission) {
        const allowCamera = await requestCameraPermission();
        if (!allowCamera) {
          return;
        }
      }
      if (!hasMicrophonePermission) {
        const allowMicrophone = await requestMicrophonePermission();
        if (!allowMicrophone) {
          return;
        }
      }
      initPusher({
        viewId,
        element: pusherRef.current,
      });
    } catch {}
  };

  useEffect(() => {
    DeviceEventEmitter.addListener('scanEnd', data => {
      pushConfig.url = data;
      relaunchPusher();
      setTimeout(() => {
        uiConfig.showPreSetting = true;
      }, 500);
    });
    return () => {
      DeviceEventEmitter.removeAllListeners('scanEnd');
    };
  }, []);

  useEffect(() => {
    return () => {
      const p = getPusher();
      if (!p) {
        return;
      }
      p.stopPush();
      p.stopAudioCapture();
      p.stopVideoCapture();
      p.stopFileRecording();
      p.destroy();
    };
  }, []);

  useEffect(() => {
    const listener = AppState.addEventListener('change', async state => {
      if (
        // Not in push
        !uiConfig.pushState ||
        // Screen push
        pushConfig.captureType ===
          VeLiveVideoCaptureType.VeLiveVideoCaptureScreen
      ) {
        return;
      }
      if (!pushConfig.backgroundMode) {
        switch (state) {
          case 'active':
            getPusher().switchAudioCapture(pushConfig.audioCaptureType);
            if (uiConfig.mode === PushMode.Audio) {
              return;
            }
            if (pushConfig.captureType !== pushConfig.backgroundCaptureType) {
              getPusher().switchVideoCapture(pushConfig.captureType);
            }
            break;
          case 'background':
            getPusher().switchAudioCapture(
              VeLiveAudioCaptureType.VeLiveAudioCaptureMuteFrame,
            );
            if (uiConfig.mode === PushMode.Audio) {
              return;
            }
            getPusher().switchVideoCapture(pushConfig.backgroundCaptureType);
            if (
              pushConfig.backgroundCaptureType ===
              VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage
            ) {
              const exist = await RNFS.exists(
                RNFS.CachesDirectoryPath + '/watermark.jpg',
              );
              if (!exist) {
                switch (Platform.OS) {
                  case 'android':
                    await RNFS.copyFileAssets(
                      'watermark.jpg',
                      RNFS.CachesDirectoryPath + '/watermark.jpg',
                    );
                    break;
                  case 'ios':
                    await RNFS.copyFile(
                      RNFS.MainBundlePath + '/watermark.jpg',
                      RNFS.CachesDirectoryPath + '/watermark.jpg',
                    );
                    break;
                  default:
                    break;
                }
              }
              const image = Image.resolveAssetSource({
                uri: RNFS.CachesDirectoryPath + '/watermark.jpg',
              });
              getPusher().updateCustomImage(image);
            }
            break;
          default:
            break;
        }
      } else {
        switch (state) {
          case 'active':
            toggleBackground(false);
            if (Platform.OS === 'ios' && uiConfig.mode === PushMode.Video) {
              getPusher().switchVideoCapture(pushConfig.captureType);
            }
            break;
          case 'background':
            toggleBackground(true);
            if (Platform.OS === 'ios' && uiConfig.mode === PushMode.Video) {
              getPusher().switchVideoCapture(
                VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
              );
            }
            break;
          default:
            break;
        }
      }
    });
    return () => {
      listener.remove();
    };
  }, []);

  return (
    <View style={styles.wrap}>
      {/* Push Preview */}
      {ui.showVideoCaptureView ? (
        <NativeViewComponent
          viewId={viewId}
          ref={pusherRef}
          style={{
            width: '100%',
            height: '100%',
            display:
              push.captureType ===
              VeLiveVideoCaptureType.VeLiveVideoCaptureScreen
                ? 'none'
                : 'flex',
          }}
          onLoad={onViewLoad}
          kind={
            Platform.select({
              android: 'SurfaceView',
              ios: 'UIView',
            })!
          }
        />
      ) : (
        <View
          style={{
            width: '100%',
            height: '100%',
            backgroundColor: '#000',
          }}
        />
      )}

      {ui.pushState && (
        <TouchableWithoutFeedback
          onPress={() => {
            navigation.navigate('Home');
          }}>
          <Icon style={styles.close} name="close" />
        </TouchableWithoutFeedback>
      )}
      {!ui.pushState && (
        <View style={styles.btnWrap}>
          {list.map(item => (
            <View
              key={item.value}
              style={{
                ...styles.btn,
                backgroundColor:
                  ui.mode === item.value ? '#108ee9' : 'transparent',
              }}>
              <TouchableWithoutFeedback
                onPress={async () => {
                  uiConfig.mode = item.value;
                  stopPushExternalVideoFrame();
                  stopPushExternalAudioFrame();
                  if (item.value === PushMode.Video) {
                    pushConfig.captureType =
                      VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera;
                    getPusher().switchVideoCapture(
                      VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera,
                    );
                    relaunchPusher();
                  } else if (item.value === PushMode.Audio) {
                    pushConfig.captureType =
                      VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage;
                    getPusher().switchVideoCapture(
                      VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
                    );
                  } else if (item.value === PushMode.Screen) {
                    pushConfig.captureType =
                      VeLiveVideoCaptureType.VeLiveVideoCaptureScreen;
                    const hasPermission = await startScreenCapture(
                      getPusher(),
                      {
                        enableAppAudio: true,
                      },
                    );
                    uiConfig.screenPermission = hasPermission;
                    if (hasPermission) {
                      toggleBackground(true);
                      getPusher().switchVideoCapture(
                        VeLiveVideoCaptureType.VeLiveVideoCaptureScreen,
                      );
                    }
                  } else if (item.value === PushMode.File) {
                    pushConfig.captureType =
                      VeLiveVideoCaptureType.VeLiveVideoCaptureExternal;
                    getPusher().switchVideoCapture(
                      VeLiveVideoCaptureType.VeLiveVideoCaptureExternal,
                    );
                    pushConfig.audioCaptureType =
                      VeLiveAudioCaptureType.VeLiveAudioCaptureExternal;
                    getPusher().switchAudioCapture(
                      VeLiveAudioCaptureType.VeLiveAudioCaptureExternal,
                    );
                    startPushExternalVideoFrame();
                    startPushExternalAudioFrame();
                  }
                }}>
                <Text style={{color: ui.mode === item.value ? '#fff' : '#fff'}}>
                  {item.label}
                </Text>
              </TouchableWithoutFeedback>
            </View>
          ))}
        </View>
      )}
      {showStartBtn &&
        ((ui.mode === PushMode.Screen && ui.screenPermission) ||
          ui.mode !== PushMode.Screen) && (
          <Button
            style={styles.startBtn}
            type="primary"
            onPress={() => {
              start();
            }}>
            Start Push
          </Button>
        )}
      <Setting />
      <Panel />
    </View>
  );
};
export default Push;
