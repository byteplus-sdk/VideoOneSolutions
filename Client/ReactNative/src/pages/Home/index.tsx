import React, {useEffect} from 'react';
import type {NativeStackScreenProps} from '@react-navigation/native-stack';
import {Icon, View, WhiteSpace, WingBlank} from '@ant-design/react-native';
import {Image, Text, StyleSheet, TouchableWithoutFeedback} from 'react-native';
import type {RootStackParamList} from '../type';
import notifee from '@notifee/react-native';
import Orientation from 'react-native-orientation-locker';

const styles = StyleSheet.create({
  list: {
    height: 200,
  },
  listItem: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    flexDirection: 'row',
    marginBottom: 12,
    padding: 16,
    borderRadius: 8,
    backgroundColor: '#fff',
    shadowColor: '#000',
  },
  left: {
    display: 'flex',
    alignItems: 'center',
    flexDirection: 'row',
  },
  icon: {
    width: 32,
    height: 32,
    borderRadius: 50,
  },
  text: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
    marginLeft: 8,
  },
});

const pageList = [
  {
    icon: require('../../../assets/live_pull_icon.png'),
    title: 'Pull',
    target: 'Pull',
  },
  {
    icon: require('../../../assets/live_push_icon.png'),
    title: 'Push',
    target: 'Push',
  },
] as const;

const Home = ({
  navigation,
}: NativeStackScreenProps<RootStackParamList, 'Home'>) => {
  useEffect(() => {
    const requestPermission = async () => {
      await notifee.requestPermission();
    };

    requestPermission();
  }, []);

  useEffect(() => {
    Orientation.lockToPortrait();
  }, []);

  return (
    <View>
      <WhiteSpace />
      <WingBlank>
        <View style={styles.list}>
          {pageList.map((item, index) => {
            return (
              <TouchableWithoutFeedback
                key={index}
                onPress={() => {
                  navigation.navigate(item.target);
                }}>
                <View style={styles.listItem}>
                  <View style={styles.left}>
                    <Image style={styles.icon} source={item.icon} />
                    <Text style={styles.text}>{item.title}</Text>
                  </View>
                  <Icon name="right" />
                </View>
              </TouchableWithoutFeedback>
            );
          })}
        </View>
      </WingBlank>
    </View>
  );
};

export default Home;
