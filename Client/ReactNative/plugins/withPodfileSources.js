// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

const { withDangerousMod } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

const withPodfileSources = (config) => {
  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const podfilePath = path.join(config.modRequest.platformProjectRoot, 'Podfile');

      if (fs.existsSync(podfilePath)) {
        let podfileContent = fs.readFileSync(podfilePath, 'utf8');

        if (!podfileContent.includes("source 'https://cdn.cocoapods.org/'")) {
          const sources = [
            "source 'https://cdn.cocoapods.org/'",
            "source 'https://github.com/CocoaPods/Specs.git'",
            "source 'https://github.com/volcengine/volcengine-specs.git'",
            "source 'https://github.com/byteplus-sdk/byteplus-specs.git'"
          ].join('\n');

          const firstRequireIndex = podfileContent.indexOf('require File.join');
          if (firstRequireIndex !== -1) {
            podfileContent = podfileContent.slice(0, firstRequireIndex) +
                           sources + '\n\n' +
                           podfileContent.slice(firstRequireIndex);
          }

          fs.writeFileSync(podfilePath, podfileContent);
          console.log('✅ Added CocoaPods sources to Podfile');
        }
      }

      return config;
    },
  ]);
};

module.exports = withPodfileSources;
