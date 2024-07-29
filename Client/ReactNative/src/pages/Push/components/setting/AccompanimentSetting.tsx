import {
  WhiteSpace,
  Slider,
  Switch,
  Button,
  List,
  View,
} from '@ant-design/react-native';
import React, {useCallback, useState} from 'react';
import {useSnapshot} from 'valtio';
import {accompanimentConfig} from '@/store/push/accompaniment';
import {Platform, ScrollView} from 'react-native';
import {getPusher} from '@/store/push/pusher';
import type {VeLiveMediaPlayer} from '@byteplus/react-native-live-push';
import RNFS from 'react-native-fs';
import {addLog} from '@/store/push/info';

let player: VeLiveMediaPlayer | null = null;

const AccompanimentSetting = () => {
  const accompaniment = useSnapshot(accompanimentConfig);
  const [playing, setPlaying] = useState(false);

  const startPlay = useCallback(async () => {
    const pusher = getPusher();
    player = pusher.createPlayer();
    try {
      const exist = await RNFS.exists(
        RNFS.CachesDirectoryPath + '/bg_music.mp3',
      );
      if (!exist) {
        switch (Platform.OS) {
          case 'android':
            await RNFS.copyFileAssets(
              'bg_music.mp3',
              RNFS.CachesDirectoryPath + '/bg_music.mp3',
            );
            break;
          case 'ios':
            await RNFS.copyFile(
              RNFS.MainBundlePath + '/bg_music.mp3',
              RNFS.CachesDirectoryPath + '/bg_music.mp3',
            );
            break;
          default:
            break;
        }
      }
      player.prepare(RNFS.CachesDirectoryPath + '/bg_music.mp3');
      player.setListener({
        onError(error) {
          console.log('error', error);
          addLog('Play accompaniment error: ' + error);
        },
        onStart() {
          player?.enableMixer(accompaniment.mixToLive);
          addLog('Start play accompaniment');
        },
        onStop() {
          addLog('Stop play accompaniment');
        },
      });
      player.start();
    } catch (error) {
      console.error(error);
    }
    setPlaying(true);
  }, [accompaniment.mixToLive]);

  const stopPlay = () => {
    if (!player) {
      return;
    }
    player?.stop();
  };

  const pausePlay = () => {
    if (!player) {
      return;
    }
    if (!accompaniment.enable) {
      return;
    }
    if (playing) {
      player?.pause();
      setPlaying(false);
    } else {
      player?.resume();
      setPlaying(true);
    }
  };

  return (
    <ScrollView>
      <List>
        <List.Item
          extra={
            <Switch
              checked={accompaniment.enable}
              onChange={value => {
                accompanimentConfig.enable = value;
                if (value) {
                  startPlay();
                } else {
                  stopPlay();
                }
              }}
            />
          }>
          Accompaniment Music
        </List.Item>
        <List.Item
          extra={
            <Button
              onPress={() => {
                pausePlay();
              }}>
              Resume/Pause
            </Button>
          }>
          Music Control
        </List.Item>
        <List.Item
          extra={
            <Switch
              checked={accompaniment.mixToLive}
              onChange={value => {
                accompanimentConfig.mixToLive = value;
                player?.enableMixer(value);
              }}
            />
          }>
          Mix to Stream
        </List.Item>
        <List.Item
          extra={
            <View style={{width: 200}}>
              <Slider
                defaultValue={accompaniment.volume}
                onChange={value => {
                  accompanimentConfig.volume = value as number;
                  player?.setBGMVolume(value as number);
                }}
                step={0.01}
                min={0}
                max={1}
              />
            </View>
          }>
          Accompaniment Volume
        </List.Item>
      </List>
      <WhiteSpace />
    </ScrollView>
  );
};

export default AccompanimentSetting;
