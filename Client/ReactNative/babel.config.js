// babel.config.js
//
// Required for Expo SDK 55 + react-native-reanimated v4.
//
// react-native-reanimated v4 extracted its worklets runtime into a separate
// package (react-native-worklets). The Babel plugin that transforms worklet
// functions now lives in 'react-native-worklets/plugin' and must be listed
// here explicitly — babel-preset-expo does NOT include it automatically.
//
// ⚠️  Plugin order matters: 'react-native-worklets/plugin' must come LAST.

module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // Required by react-native-reanimated v4 — MUST be last
      'react-native-worklets/plugin',
    ],
  };
};
