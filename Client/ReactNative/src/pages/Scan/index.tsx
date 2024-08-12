import {View} from '@ant-design/react-native';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import React from 'react';
import {DeviceEventEmitter, StyleSheet, Text} from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCodeScanner,
} from 'react-native-vision-camera';
import {RootStackParamList} from '../type';

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
  },
  innerWrap: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  border: {
    backgroundColor: 'transparent',
    borderColor: 'green',
    borderWidth: 2,
    borderRadius: 10,
    width: 300,
    height: 300,
    position: 'absolute',
  },
  rectangleText: {
    position: 'absolute',
    top: '50%',
    transform: [{translateY: 162}],
    textAlign: 'center',
    color: 'white',
    fontSize: 20,
  },
});

const Scan = ({
  navigation,
}: NativeStackScreenProps<RootStackParamList, 'Scan'>) => {
  const device = useCameraDevice('back');
  const [isActive, setIsActive] = React.useState(true);

  const codeScanner = useCodeScanner({
    codeTypes: ['qr', 'ean-13'],
    onCodeScanned: code => {
      if (code?.[0].value) {
        setIsActive(false);
        navigation.goBack();
        DeviceEventEmitter.emit('scanEnd', code?.[0].value);
      }
    },
  });

  if (device == null) {
    return <Text>Start Failed</Text>;
  }
  return (
    <View style={styles.wrap}>
      <Camera
        codeScanner={codeScanner}
        style={StyleSheet.absoluteFill}
        device={device}
        photoQualityBalance="speed"
        isActive={isActive}
      />
      <View style={styles.innerWrap}>
        <View style={[styles.border, {transform: [{translateY: 0}]}]} />
        <Text style={styles.rectangleText}>
          Put the QR code into the box and it will be scanned automatically
        </Text>
      </View>
    </View>
  );
};

export default Scan;
