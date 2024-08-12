import {
  Button,
  Flex,
  Icon,
  Switch,
  TextareaItem,
  WhiteSpace,
  WingBlank,
  List,
  Radio,
  InputItem,
  Toast,
  Picker,
  View,
} from '@ant-design/react-native';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import React, {useEffect, useState} from 'react';
import {
  DeviceEventEmitter,
  StyleSheet,
  Text,
  TouchableOpacity,
  TouchableWithoutFeedback,
  ScrollView,
  Keyboard,
} from 'react-native';
import {useSnapshot} from 'valtio';
import {useCameraPermission} from 'react-native-vision-camera';

import {
  VeLivePlayerFormat,
  VeLivePlayerProtocol,
} from '@byteplus/react-native-live-pull';

import {
  pullConfig,
  vePlayerResolutionList,
  vePlayerResolutionMap,
} from '../../store/pull/config';
import {RootStackParamList} from '../type';
import PickerText from './components/PickerText';

const styles = StyleSheet.create({
  textarea: {
    borderRadius: 8,
  },
  row: {
    gap: 16,
  },
  miniRow: {
    gap: 4,
  },
  col: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    color: '#333',
    backgroundColor: '#fff',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 8,
    minWidth: 150,
    maxWidth: '45%',
  },
  radioGroup: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'flex-start',
    flexWrap: 'wrap',
    gap: 4,
  },
  radio: {
    flexShrink: 0,
    width: '30%',
  },
  modalMask: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  modal: {
    width: '80%',
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  modalBtnWrap: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 16,
    flexDirection: 'row',
  },
  modalBtn: {
    width: '48%',
  },
});

const defaultStream = {
  url: '',
  resolution: 0,
  bitrate: '4000',
};

const Pull = ({
  navigation,
}: NativeStackScreenProps<RootStackParamList, 'Pull'>) => {
  const pull = useSnapshot(pullConfig);
  const {requestPermission, hasPermission} = useCameraPermission();
  // Popup Visible
  const [visible, setVisible] = useState(false);
  // Scan Mode
  const [scanMode, setScanMode] = useState<'url' | 'stream'>('url');
  // Current Popup Content
  const [stream, setStream] = useState(defaultStream);

  useEffect(() => {
    DeviceEventEmitter.addListener('scanEnd', data => {
      if (scanMode === 'stream') {
        setStream(streamItem => ({
          ...streamItem,
          url: data,
        }));
      } else {
        pullConfig.url = data;
      }
    });
    return () => {
      DeviceEventEmitter.removeAllListeners('scanEnd');
    };
  }, [scanMode, setStream]);

  /** Add Stream */
  const addStream = () => {
    setStream(defaultStream);
    setVisible(true);
  };

  /** Scan */
  const scan = (mode: 'url' | 'stream' = 'url') => {
    setScanMode(mode);
    if (!hasPermission) {
      requestPermission().then(() => {
        navigation.navigate('Scan');
      });
    } else {
      navigation.navigate('Scan');
    }
  };

  return (
    <>
      <ScrollView>
        <WingBlank>
          <WhiteSpace />
          {pull.abr ? (
            <List>
              {pull.streams.map(item => {
                return (
                  <List.Item align="top" wrap key={item.resolution}>
                    <TouchableOpacity
                      onPress={() => {
                        setStream({
                          ...item,
                          bitrate: String(item.bitrate),
                        });
                        setVisible(true);
                      }}>
                      <>
                        <Text>{item.url}</Text>
                        <List.Item.Brief>
                          Bitrate: {item.bitrate}
                        </List.Item.Brief>
                        <List.Item.Brief>
                          Resolution:
                          {
                            vePlayerResolutionMap[String(item.resolution)]
                              ?.label
                          }
                        </List.Item.Brief>
                      </>
                    </TouchableOpacity>
                  </List.Item>
                );
              })}
            </List>
          ) : (
            <TextareaItem
              style={styles.textarea}
              rows={4}
              placeholder="Pull URL"
              defaultValue={pull.url}
              onChange={url => {
                pullConfig.url = url || '';
              }}
            />
          )}
          <WhiteSpace />
          {pull.abr ? (
            <Flex justify="end" style={styles.row}>
              <Button
                type="primary"
                onPress={() => {
                  addStream();
                }}>
                Add Stream
              </Button>
              <Button
                type="warning"
                onPress={() => {
                  pullConfig.streams = [];
                }}>
                Clear Stream
              </Button>
            </Flex>
          ) : (
            <TouchableWithoutFeedback
              onPress={() => {
                scan('url');
              }}>
              <Flex style={styles.miniRow}>
                <Icon name="scan" />
                <Text>Scan QRCode</Text>
              </Flex>
            </TouchableWithoutFeedback>
          )}
          <WhiteSpace />
          <Button
            type="primary"
            onPress={() => {
              if (pull.abr && !pull.streams.length) {
                Toast.info('Please add stream');
              } else if (!pull.abr && !pull.url) {
                Toast.info('Please scan or input url');
              } else {
                navigation.navigate('PullDetail');
              }
            }}>
            Start Play
          </Button>
          <WhiteSpace />
          <Flex style={styles.row} wrap="wrap">
            <Flex.Item style={styles.col}>
              <Text>ABR</Text>
              <Switch
                checked={pull.abr}
                onChange={abr => {
                  pullConfig.abr = abr;
                }}
              />
            </Flex.Item>
            <Flex.Item style={styles.col}>
              <Text>SEI</Text>
              <Switch
                checked={pull.sei}
                onChange={sei => {
                  pullConfig.sei = sei;
                }}
              />
            </Flex.Item>
            {pull.abr && (
              <Flex.Item style={styles.col}>
                <Text>Auto Switch Resolution</Text>
                <Switch
                  checked={pull.enableSwitchAbr}
                  onChange={enableSwitch => {
                    pullConfig.enableSwitchAbr = enableSwitch;
                  }}
                />
              </Flex.Item>
            )}
            <Flex.Item style={styles.col}>
              <Picker
                value={[pull.format]}
                onChange={value => {
                  pullConfig.format = value[0] as VeLivePlayerFormat;
                  if (
                    pullConfig.format !==
                      VeLivePlayerFormat.VeLivePlayerFormatFLV &&
                    pull.protocol ===
                      VeLivePlayerProtocol.VeLivePlayerProtocolQUIC
                  ) {
                    pullConfig.protocol =
                      VeLivePlayerProtocol.VeLivePlayerProtocolTCP;
                  }
                }}
                data={[
                  {
                    label: 'FLV',
                    value: VeLivePlayerFormat.VeLivePlayerFormatFLV,
                  },
                  {
                    label: 'HLS',
                    value: VeLivePlayerFormat.VeLivePlayerFormatHLS,
                  },
                  {
                    label: 'RTM',
                    value: VeLivePlayerFormat.VeLivePlayerFormatRTM,
                  },
                ]}>
                <PickerText>Format</PickerText>
              </Picker>
            </Flex.Item>
            <Flex.Item style={styles.col}>
              <Picker
                value={[pull.protocol]}
                onChange={value => {
                  if (
                    pull.format !== VeLivePlayerFormat.VeLivePlayerFormatFLV &&
                    value[0] === VeLivePlayerProtocol.VeLivePlayerProtocolQUIC
                  ) {
                    Toast.info('QUIC protocol only support FLV format', 0.5);
                    return;
                  }
                  pullConfig.protocol = value[0] as VeLivePlayerProtocol;
                }}
                data={[
                  {
                    label: 'TCP',
                    value: VeLivePlayerProtocol.VeLivePlayerProtocolTCP,
                  },
                  {
                    label: 'QUIC',
                    value: VeLivePlayerProtocol.VeLivePlayerProtocolQUIC,
                  },
                  {
                    label: 'TLS',
                    value: VeLivePlayerProtocol.VeLivePlayerProtocolTLS,
                  },
                ]}>
                <PickerText>Protocol</PickerText>
              </Picker>
            </Flex.Item>
          </Flex>
        </WingBlank>
      </ScrollView>
      <TouchableWithoutFeedback
        onPress={() => {
          Keyboard.dismiss();
        }}>
        <View
          style={{
            ...StyleSheet.absoluteFillObject,
            display: visible ? 'flex' : 'none',
            height: '100%',
            justifyContent: 'center',
            alignItems: 'center',
          }}>
          <View style={styles.modalMask} />
          <View style={styles.modal}>
            <Radio.Group
              style={styles.radioGroup}
              value={stream.resolution}
              onChange={e => {
                const value = e.target.value;
                setStream({
                  ...stream,
                  resolution: Number(value),
                  bitrate: String(
                    vePlayerResolutionMap[String(value)]?.bitrate,
                  ),
                });
              }}>
              {vePlayerResolutionList.map(item => {
                return (
                  <Radio
                    key={item.value}
                    value={item.value}
                    style={styles.radio}>
                    {item.label}
                  </Radio>
                );
              })}
            </Radio.Group>
            <InputItem
              placeholder="URL"
              value={stream.url}
              onChange={url => {
                setStream({
                  ...stream,
                  url: String(url),
                });
              }}
              extra={<Icon name="scan" />}
              onExtraClick={() => {
                scan('stream');
              }}
            />
            <InputItem
              value={stream.bitrate}
              placeholder="bitrate, unit: kbps"
              onChange={value => {
                setStream({
                  ...stream,
                  bitrate: String(value),
                });
              }}
            />
            <View style={styles.modalBtnWrap}>
              <Button
                type="ghost"
                style={styles.modalBtn}
                onPress={() => {
                  setVisible(false);
                }}>
                Cancel
              </Button>
              <Button
                type="ghost"
                style={styles.modalBtn}
                onPress={() => {
                  const index = pullConfig.streams.findIndex(
                    item => item.resolution === stream.resolution,
                  );
                  const item = {
                    ...stream,
                    bitrate: Number(stream.bitrate),
                  };
                  if (
                    !item.bitrate ||
                    !Number.isInteger(item.resolution) ||
                    !item.url
                  ) {
                    Toast.info('Please fill in the required fields');
                    return;
                  }
                  if (index > -1) {
                    pullConfig.streams.splice(index, 1, item);
                  } else {
                    pullConfig.streams.push(item);
                  }
                  setVisible(false);
                }}>
                Add
              </Button>
            </View>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </>
  );
};

export default Pull;
