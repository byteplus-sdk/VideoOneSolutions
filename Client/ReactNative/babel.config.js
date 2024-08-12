const path = require('path');
const root = path.join(__dirname, '..');

module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ['import', {libraryName: '@ant-design/react-native'}],
    ['@babel/plugin-proposal-decorators', {version: '2023-11'}],
    ['@babel/plugin-transform-class-static-block'],
    [
      require.resolve('babel-plugin-module-resolver'),
      {
        root: ['.'],
        alias: {
          '@': './src',
        },
        extensions: ['.ts', '.tsx'],
      },
    ],
  ],
};
