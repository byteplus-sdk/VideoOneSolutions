/**
 * @format
 */

import {AppRegistry} from 'react-native';
import {name as appName} from './app.json';
import App from './src/App';
import notifee from '@notifee/react-native';

notifee.registerForegroundService(() => {
  return new Promise(() => {});
});

AppRegistry.registerComponent(appName, () => App);
