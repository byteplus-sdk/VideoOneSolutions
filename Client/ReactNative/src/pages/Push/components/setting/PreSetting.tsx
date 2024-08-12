import {
  WhiteSpace,
  WingBlank,
  InputItem,
  Flex,
  Picker,
  Icon,
  List,
  Switch,
} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {pushConfig} from '@/store/push/config';
import {Platform, StyleSheet} from 'react-native';
import {
  VeLiveVideoResolution,
  VeLiveVideoCodec,
  VeLivePusherRenderMode,
  VeLiveVideoCaptureType,
} from '@byteplus/react-native-live-push';
import {useCameraPermission} from 'react-native-vision-camera';
import {useNavigation} from '@react-navigation/native';
import {PushMode, uiConfig} from '@/store/push/ui';
import {getPusher, relaunchPusher} from '@/store/push/pusher';

const styles = StyleSheet.create({
  miniRow: {
    gap: 4,
  },
});

const PreSetting = () => {
  const {requestPermission, hasPermission} = useCameraPermission();
  const push = useSnapshot(pushConfig);
  const ui = useSnapshot(uiConfig);
  const navigation = useNavigation<any>();

  const scan = () => {
    const doScan = () => {
      navigation.navigate('Scan');
      uiConfig.showPreSetting = false;
    };
    if (!hasPermission) {
      requestPermission().then(() => {
        doScan();
      });
    } else {
      doScan();
    }
  };

  const isVideo = ui.mode !== PushMode.Audio;

  return (
    <WingBlank>
      <List>
        <InputItem
          defaultValue={push.url}
          extra={
            <Flex style={styles.miniRow}>
              <Icon name="scan" />
            </Flex>
          }
          onExtraClick={scan}
          onChange={url => {
            pushConfig.url = url;
          }}>
          Push URL
        </InputItem>
        {ui.mode === PushMode.Video ? (
          <>
            <Picker
              value={[push.videoResolution]}
              onChange={value => {
                pushConfig.videoResolution = value[0] as VeLiveVideoResolution;
                relaunchPusher();
              }}
              data={
                Platform.OS === 'android'
                  ? [
                      {
                        label: '360P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution360P,
                      },
                      {
                        label: '480P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution480P,
                      },
                      {
                        label: '540P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution540P,
                      },
                      {
                        label: '720P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution720P,
                      },
                      {
                        label: '1080P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution1080P,
                      },
                    ]
                  : [
                      {
                        label: '480P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution480P,
                      },
                      {
                        label: '540P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution540P,
                      },
                      {
                        label: '720P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution720P,
                      },
                      {
                        label: '1080P',
                        value: VeLiveVideoResolution.VeLiveVideoResolution1080P,
                      },
                    ]
              }>
              <List.Item>Video Capture Resolution</List.Item>
            </Picker>
            <Picker
              value={[push.videoFps]}
              onChange={value => {
                pushConfig.videoFps = value[0] as number;
                relaunchPusher();
              }}
              data={[
                {label: '15', value: 15},
                {label: '20', value: 20},
                {label: '25', value: 25},
                {label: '30', value: 30},
              ]}>
              <List.Item>Video Capture FPS</List.Item>
            </Picker>
          </>
        ) : (
          <></>
        )}
        {isVideo ? (
          <>
            <Picker
              value={[push.videoEncodeResolution]}
              onChange={value => {
                pushConfig.videoEncodeResolution =
                  value[0] as VeLiveVideoResolution;
              }}
              data={[
                {
                  label: '360P',
                  value: VeLiveVideoResolution.VeLiveVideoResolution360P,
                },
                {
                  label: '480P',
                  value: VeLiveVideoResolution.VeLiveVideoResolution480P,
                },
                {
                  label: '540P',
                  value: VeLiveVideoResolution.VeLiveVideoResolution540P,
                },
                {
                  label: '720P',
                  value: VeLiveVideoResolution.VeLiveVideoResolution720P,
                },
                {
                  label: '1080P',
                  value: VeLiveVideoResolution.VeLiveVideoResolution1080P,
                },
              ]}>
              <List.Item>Video Encode Resolution</List.Item>
            </Picker>
            <Picker
              value={[push.videoEncodeFps]}
              onChange={value => {
                pushConfig.videoEncodeFps = value[0] as number;
              }}
              data={[
                {label: '15', value: 15},
                {label: '20', value: 20},
                {label: '25', value: 25},
                {label: '30', value: 30},
              ]}>
              <List.Item>Video Encode FPS</List.Item>
            </Picker>
            <Picker
              value={[push.videoEncodeType]}
              onChange={value => {
                pushConfig.videoEncodeType = value[0] as VeLiveVideoCodec;
              }}
              data={[
                {
                  label: 'H264',
                  value: VeLiveVideoCodec.VeLiveVideoCodecH264,
                },
                {
                  label: 'H265',
                  value: VeLiveVideoCodec.VeLiveVideoCodecByteVC1,
                },
              ]}>
              <List.Item>Video Encode Type</List.Item>
            </Picker>
            <Picker
              value={[push.gop]}
              onChange={value => {
                pushConfig.gop = value[0] as number;
              }}
              data={[
                {label: '2', value: 2},
                {label: '3', value: 3},
                {label: '4', value: 4},
                {label: '5', value: 5},
              ]}>
              <List.Item>Video Encode GOP</List.Item>
            </Picker>
            <List.Item
              extra={
                <Switch
                  checked={push.bFrame}
                  onChange={value => {
                    pushConfig.bFrame = value;
                  }}
                />
              }>
              B-Frame
            </List.Item>
          </>
        ) : (
          <></>
        )}
        <InputItem
          defaultValue={push.bitrate.toString()}
          onChange={targetBitrate => {
            pushConfig.bitrate = Number(targetBitrate);
          }}>
          Target Bitrate
        </InputItem>
        <InputItem
          defaultValue={push.minBitrate.toString()}
          onChange={minBitrate => {
            pushConfig.minBitrate = Number(minBitrate);
          }}>
          Min Bitrate
        </InputItem>
        <InputItem
          defaultValue={push.maxBitrate.toString()}
          onChange={maxBitrate => {
            pushConfig.maxBitrate = Number(maxBitrate);
          }}>
          Max Bitrate
        </InputItem>
        {ui.mode === PushMode.Video ? (
          <Picker
            value={[push.fillMode]}
            onChange={value => {
              pushConfig.fillMode = value[0] as VeLivePusherRenderMode;
              getPusher().setRenderFillMode(pushConfig.fillMode);
            }}
            data={[
              {
                label: 'Fit',
                value: VeLivePusherRenderMode.VeLivePusherRenderModeFit,
              },
              {
                label: 'Fill',
                value: VeLivePusherRenderMode.VeLivePusherRenderModeFill,
              },
              {
                label: 'Hidden',
                value: VeLivePusherRenderMode.VeLivePusherRenderModeHidden,
              },
            ]}>
            <List.Item>Preview Fill Mode</List.Item>
          </Picker>
        ) : (
          <></>
        )}
        {[PushMode.Video, PushMode.Audio].includes(ui.mode) ? (
          <>
            <List.Item
              extra={
                <Switch
                  checked={push.backgroundMode}
                  onChange={value => {
                    pushConfig.backgroundMode = value;
                  }}
                />
              }>
              Background Mode
            </List.Item>
            {Platform.OS === 'android' && (
              <Picker
                value={[push.backgroundCaptureType]}
                onChange={value => {
                  pushConfig.backgroundCaptureType = value[0] as number;
                }}
                data={[
                  {
                    label: 'Black',
                    value: VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
                  },
                  {
                    label: 'Last Frame',
                    value: VeLiveVideoCaptureType.VeLiveVideoCaptureLastFrame,
                  },
                  {
                    label: 'Custom Image',
                    value: VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage,
                  },
                ]}>
                <List.Item>Background Video Capture Type</List.Item>
              </Picker>
            )}
          </>
        ) : (
          <></>
        )}
        {isVideo ? (
          <>
            <List.Item
              extra={
                <Switch
                  checked={push.enableAccelerate}
                  onChange={value => {
                    pushConfig.enableAccelerate = value;
                  }}
                />
              }>
              Hardware Encode
            </List.Item>
          </>
        ) : (
          <></>
        )}
      </List>
      <WhiteSpace />
    </WingBlank>
  );
};

export default PreSetting;
