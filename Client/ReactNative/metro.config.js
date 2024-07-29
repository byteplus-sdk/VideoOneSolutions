const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');
const exclusionList = require('metro-config/src/defaults/exclusionList');

const root = path.join(__dirname, '..');

const modules = [
  '@byteplus/react-native-live-pull',
  '@byteplus/react-native-live-push',
];

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * @type {import('metro-config').MetroConfig}
 */
const config = {
  projectRoot: __dirname,
  watchFolders: [root],

  resolver: {
    sourceExts: ['ts', 'tsx', 'js', 'jsx', 'json'],
    blacklistRE: exclusionList(
      modules.map(
        m =>
          new RegExp(
            `^${escape(path.join(root, 'modules', m, 'node_modules'))}\\/.*$`,
          ),
      ),
    ),

    resolveRequest: (context, moduleName, platform) => {
      if (
        moduleName === 'react-native' ||
        moduleName.startsWith('react-native/')
      ) {
        return {
          filePath: require.resolve(moduleName, {
            paths: [__dirname],
          }),
          type: 'sourceFile',
        };
      }

      // Optionally, chain to the standard Metro resolver.
      return context.resolveRequest(context, moduleName, platform);
    },

    // unstable_enableSymlinks: true,
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
