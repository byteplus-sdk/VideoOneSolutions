import {Checkbox, Radio, WhiteSpace, WingBlank} from '@ant-design/react-native';
import React from 'react';
import {StyleSheet, Text} from 'react-native';
import {useSnapshot} from 'valtio';

import {
  VeLivePlayerFillMode,
  VeLivePlayerMirror,
  VeLivePlayerRotation,
  type VeLivePlayerResolution,
} from '@byteplus/react-native-live-pull';

import {
  pullConfig,
  vePlayerResolutionMap,
} from '../../../../../store/pull/config';
import {getPlayer, playerConfig} from '../../../../../store/pull/player';

const styles = StyleSheet.create({
  row: {
    gap: 16,
  },
  radioGroup: {
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    gap: 4,
  },
});

const VideoSetting = () => {
  const {abr, streams} = useSnapshot(pullConfig);
  const {rotation, fillMode, mirror, resolution, enableSuperResolution} =
    useSnapshot(playerConfig);

  return (
    <WingBlank>
      <WhiteSpace />
      <Text>Rotate</Text>
      <WhiteSpace />
      <Radio.Group
        style={styles.radioGroup}
        value={rotation}
        onChange={e => {
          playerConfig.rotation = e.target.value as VeLivePlayerRotation;
          getPlayer()?.setRenderRotation(
            e.target.value as VeLivePlayerRotation,
          );
        }}>
        <Radio value={0}>0</Radio>
        <Radio value={1}>90</Radio>
        <Radio value={2}>180</Radio>
        <Radio value={3}>270</Radio>
      </Radio.Group>
      <WhiteSpace />
      <Text>FillMode</Text>
      <WhiteSpace />
      <Radio.Group
        style={styles.radioGroup}
        value={fillMode}
        onChange={e => {
          playerConfig.fillMode = e.target.value as VeLivePlayerFillMode;
          getPlayer()?.setRenderFillMode(
            e.target.value as VeLivePlayerFillMode,
          );
        }}>
        <Radio value={VeLivePlayerFillMode.VeLivePlayerFillModeFullFill}>
          FullFill
        </Radio>
        <Radio value={VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit}>
          AspectFit
        </Radio>
        <Radio value={VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill}>
          AspectFill
        </Radio>
      </Radio.Group>
      <WhiteSpace />
      <Text>Mirror</Text>
      <WhiteSpace />
      <Radio.Group
        style={styles.radioGroup}
        value={mirror}
        onChange={e => {
          playerConfig.mirror = e.target.value as VeLivePlayerMirror;
          getPlayer()?.setRenderMirror(e.target.value as VeLivePlayerMirror);
        }}>
        <Radio value={VeLivePlayerMirror.VeLivePlayerMirrorNone}>None</Radio>
        <Radio value={VeLivePlayerMirror.VeLivePlayerMirrorHorizontal}>
          Horizontal
        </Radio>
        <Radio value={VeLivePlayerMirror.VeLivePlayerMirrorVertical}>
          Vertical
        </Radio>
      </Radio.Group>
      <WhiteSpace />
      <Text>Config</Text>
      <WhiteSpace />
      {abr && (
        <>
          <Radio.Group
            style={styles.radioGroup}
            value={resolution}
            onChange={e => {
              playerConfig.resolution = e.target
                .value as VeLivePlayerResolution;
              getPlayer()?.switchResolution(
                e.target.value as VeLivePlayerResolution,
              );
            }}>
            {streams.map(stream => (
              <Radio key={stream.resolution} value={stream.resolution}>
                {vePlayerResolutionMap[stream.resolution].label}
              </Radio>
            ))}
          </Radio.Group>
          <WhiteSpace />
        </>
      )}
      <Checkbox
        checked={enableSuperResolution}
        onChange={e => {
          playerConfig.enableSuperResolution = e.target.checked;
          getPlayer()?.setEnableSuperResolution(e.target.checked);
        }}>
        Super Resolution
      </Checkbox>
      <WhiteSpace />
    </WingBlank>
  );
};

export default VideoSetting;
