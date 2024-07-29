import React, {useMemo} from 'react';
import {Modal, Tabs, View, WhiteSpace} from '@ant-design/react-native';
import {
  Image,
  ScrollView,
  StyleSheet,
  TouchableWithoutFeedback,
} from 'react-native';
import Preview from './preview';
import {useSnapshot} from 'valtio';
import {PushMode, uiConfig} from '@/store/push/ui';
import Push from './push';
import PreSetting from './PreSetting';
import RecordSetting from './RecordSetting';
import AudioSetting from './AudioSetting';
import VideoSetting from './VideoSetting';
import MirrorSetting from './MirrorSetting';
import SeiSetting from './SeiSetting';
import AccompanimentSetting from './AccompanimentSetting';
import {launchImageLibrary} from 'react-native-image-picker';
import {getPusher} from '@/store/push/pusher';
import InfoSetting from './Info';
import {VeLiveVideoCaptureType} from '@byteplus/react-native-live-push';
import {pushConfig} from '@/store/push/config';

const styles = StyleSheet.create({
  settingPreview: {
    position: 'absolute',
    width: '40%',
    left: '30%',
    bottom: 80,
  },
  settingPush: {
    position: 'absolute',
    right: 16,
    bottom: 32,
  },
  image: {
    position: 'absolute',
    top: 300,
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '60%',
    left: '20%',
  },
  imageBtn: {
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
    color: '#fff',
  },
  settingPanel: {},
  panelItem: {
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  text: {
    color: '#fff',
  },
});

const Setting = () => {
  const ui = useSnapshot(uiConfig);

  const addImage = async () => {
    const res = await launchImageLibrary({
      mediaType: 'photo',
    });
    const selectImage = res.assets?.[0];
    if (selectImage?.uri) {
      const image = Image.resolveAssetSource({
        uri: selectImage.uri,
        width: selectImage.width,
        height: selectImage.height,
        scale: 1,
      });
      getPusher().switchVideoCapture(
        VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
      );
      await getPusher().updateCustomImage(image);
      pushConfig.image = image;
      pushConfig.captureType =
        VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage;
      getPusher().switchVideoCapture(
        VeLiveVideoCaptureType.VeLiveVideoCaptureCustomImage,
      );
    }
  };

  const removeImage = () => {
    pushConfig.captureType =
      VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame;
    getPusher().switchVideoCapture(
      VeLiveVideoCaptureType.VeLiveVideoCaptureDummyFrame,
    );
  };

  const tabs = useMemo(() => {
    return [
      {title: 'Record', content: <RecordSetting key="record" />},
      {title: 'Audio', content: <AudioSetting key="audio" />},
      {
        title: 'Video',
        content: <VideoSetting key="video" />,
        hidden: ui.mode !== PushMode.Video,
      },
      {
        title: 'Mirror',
        content: <MirrorSetting key="mirror" />,
        hidden: ui.mode !== PushMode.Video,
      },
      {title: 'SEI', content: <SeiSetting key="sei" />},
      {
        title: 'Accompaniment',
        content: <AccompanimentSetting key="accompaniment" />,
      },
    ].filter(item => !item.hidden);
  }, [ui.mode]);

  return (
    <>
      <View style={ui.pushState ? styles.settingPush : styles.settingPreview}>
        {ui.pushState ? <Push /> : <Preview />}
      </View>
      {ui.mode === PushMode.Audio && (
        <View style={styles.image}>
          <TouchableWithoutFeedback onPress={addImage}>
            <View style={styles.imageBtn}>Add Image</View>
          </TouchableWithoutFeedback>
          <TouchableWithoutFeedback onPress={removeImage}>
            <View style={styles.imageBtn}>Remove Image</View>
          </TouchableWithoutFeedback>
        </View>
      )}
      <View style={styles.settingPanel}>
        <Modal
          maskClosable
          popup
          animationType="slide-up"
          visible={ui.showPreSetting}
          title="Push Setting"
          onClose={() => {
            uiConfig.showPreSetting = false;
          }}>
          <ScrollView style={{maxHeight: 300}}>
            <PreSetting />
            {/* Fill content height */}
            <WhiteSpace />
          </ScrollView>
        </Modal>
        <Modal
          maskClosable
          popup
          animationType="slide-up"
          visible={ui.showPushSetting}
          onClose={() => {
            uiConfig.showPushSetting = false;
          }}>
          <Tabs tabs={tabs}>{tabs.map(item => item.content)}</Tabs>
        </Modal>
        <Modal
          maskClosable
          popup
          animationType="slide-up"
          visible={ui.showInfoPanel}
          title="Info"
          onClose={() => {
            uiConfig.showInfoPanel = false;
          }}>
          <ScrollView style={{maxHeight: 300}}>
            <InfoSetting />
            {/* Fill content height */}
            <WhiteSpace />
          </ScrollView>
        </Modal>
      </View>
    </>
  );
};

export default Setting;
