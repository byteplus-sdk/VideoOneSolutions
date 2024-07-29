import {
  WhiteSpace,
  InputItem,
  Picker,
  Switch,
  List,
} from '@ant-design/react-native';
import React from 'react';
import {useSnapshot} from 'valtio';
import {VeLiveVideoResolution} from '@byteplus/react-native-live-push';
import {recordConfig} from '@/store/push/record';
import {ScrollView, StyleSheet} from 'react-native';
import {getPusher} from '@/store/push/pusher';
import {getDefaultFileRecorderConfiguration} from '@/store/push/api';
import RNFS from 'react-native-fs';
import dayjs from 'dayjs';
import {addLog} from '@/store/push/info';
import {CameraRoll} from '@react-native-camera-roll/camera-roll';
import {PushMode, uiConfig} from '@/store/push/ui';

const styles = StyleSheet.create({
  wrap: {
    padding: 8,
    minHeight: 180,
  },
});

const RecordSetting = () => {
  const record = useSnapshot(recordConfig);
  const ui = useSnapshot(uiConfig);

  return (
    <ScrollView>
      <List style={styles.wrap}>
        <List.Item
          extra={
            <Switch
              checked={record.isRecord}
              onChange={isRecord => {
                recordConfig.isRecord = isRecord;
                if (isRecord) {
                  const configuration = getDefaultFileRecorderConfiguration();
                  const filePath = `${RNFS.CachesDirectoryPath}/record_${dayjs().format('YYYY-MM-DD_HHmmss')}.mp4`;
                  getPusher().startFileRecording(filePath, configuration, {
                    onFileRecordingError(error) {
                      addLog('Recording error: ' + error);
                    },
                    onFileRecordingStarted() {
                      addLog('Start recording, file path:' + filePath);
                    },
                    onFileRecordingStopped() {
                      addLog('Stop recording');
                      CameraRoll.saveAsset(filePath, {
                        type: 'video',
                      });
                    },
                  });
                } else {
                  getPusher().stopFileRecording();
                }
              }}
            />
          }>
          Recording Live Broadcast
        </List.Item>
        {ui.mode === PushMode.Video ? (
          <>
            <Picker
              value={[record.videoResolution]}
              onChange={value => {
                recordConfig.videoResolution =
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
              <List.Item>Video resolution</List.Item>
            </Picker>
            <Picker
              value={[record.videoEncodeFps]}
              onChange={value => {
                recordConfig.videoEncodeFps = value[0] as number;
              }}
              data={[
                {label: '15', value: 15},
                {label: '20', value: 20},
                {label: '25', value: 25},
                {label: '30', value: 30},
              ]}>
              <List.Item>Video FPS</List.Item>
            </Picker>
            <InputItem
              placeholder="Video bitrate"
              defaultValue={record.videoBitrate.toString()}
              onChange={targetBitrate => {
                recordConfig.videoBitrate = Number(targetBitrate);
              }}>
              Video bitrate
            </InputItem>
          </>
        ) : (
          <></>
        )}
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default RecordSetting;
