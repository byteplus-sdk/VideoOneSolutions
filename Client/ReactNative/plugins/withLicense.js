// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

const { withDangerousMod, withXcodeProject } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');
const {
  findFileReferenceByName,
  addFileToGroup,
} = require('./xcodeUtils');

function copyFileSync(source, target) {
  try {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(source, target);
  } catch (e) {
    console.warn(`Failed to copy file from ${source} to ${target}:`, e);
  }
}

const licPath = 'assets/ttsdk.lic';
const licName = 'ttsdk.lic'

const withVodLicense = (config) => {
  const androidConfig = withDangerousMod(config, [
    'android',
    async (androidModConfig) => {
      const targetFile = `android/app/src/main/assets/${licName}`;
      try {
        copyFileSync(licPath, targetFile);
      } catch (e) {
        console.warn('Failed to copy VOD license file for Android:', e);
      }

      return androidModConfig;
    },
  ]);

  return withXcodeProject(androidConfig, (iosConfig) => {
    const xcodeProject = iosConfig.modResults;
    const targetFileName = licName;
    const targetDir = 'videoonern'
    const targetFile = path.join('ios', targetDir, targetFileName);

    try {
      copyFileSync(licPath, targetFile);

      const fileRef = findFileReferenceByName(xcodeProject, targetFileName);
      const fileRefUUID = Object.keys(fileRef).at(0);

      if (!fileRefUUID) {
        const file = addFileToGroup(xcodeProject, targetFileName, targetDir);
        if (!file) {
          console.warn('Failed to add VOD license file to Xcode project');
        }
      }
    } catch (e) {
      console.warn('Failed to copy VOD license file for iOS:', e);
    }

    return iosConfig;
  });
};

module.exports = withVodLicense;
