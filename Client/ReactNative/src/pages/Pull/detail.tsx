import React, {useRef, useEffect, useMemo} from 'react';
import {View} from '@ant-design/react-native';
import {AppState, Platform, StyleSheet} from 'react-native';
import {useSnapshot} from 'valtio';

import {
  NativeViewComponent,
  VeLivePlayer,
} from '@byteplus/react-native-live-pull';

import {initPlayer, playerConfig} from '../../store/pull/player';
import {pullConfig} from '../../store/pull/config';
import Setting from './components/setting';
import Panel from './components/panel';

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
  },
});

const PullDetail = () => {
  const pull = useSnapshot(pullConfig);
  const viewId = useMemo(() => 'pull-view', []);
  const playerRef = useRef<VeLivePlayer>();

  const onViewLoad = async () => {
    playerRef.current = await initPlayer({
      viewId: 'pull-view',
      enableSei: pull.sei,
      networkTimeoutMs: 10000,
    });
  };

  useEffect(() => {
    const listener = AppState.addEventListener('change', state => {
      if (!playerConfig.background) {
        state === 'active' && playerRef.current?.play();
        state === 'background' && playerRef.current?.pause();
      }
    });
    return () => {
      listener.remove();
      playerRef.current?.destroy();
    };
  }, []);

  return (
    <View style={styles.wrap}>
      <NativeViewComponent
        viewId={viewId}
        style={{
          width: '100%',
          height: '100%',
        }}
        onLoad={onViewLoad}
        kind={
          Platform.select({
            android: 'SurfaceView',
            ios: 'UIView',
          })!
        }
      />
      <Panel />
      <Setting />
    </View>
  );
};

export default PullDetail;
