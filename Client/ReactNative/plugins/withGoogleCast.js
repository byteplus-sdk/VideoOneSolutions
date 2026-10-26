// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

/**
 * Expo Config Plugin for react-native-google-cast (Android only)
 *
 * What this plugin does on Android:
 *  1. Adds INTERNET & ACCESS_NETWORK_STATE permissions (already present in most apps)
 *  2. Injects the CastOptionsProvider meta-data into AndroidManifest.xml
 *  3. Initializes Google Cast lazily from MainActivity.onCreate
 *  4. Pins the Cast SDK version used by react-native-google-cast
 *
 * iOS note:
 *  A native AVRoutePickerView + AirPlayRelay is used instead of Google Cast.
 */

const {
  withAndroidManifest,
  withInfoPlist,
  withMainActivity,
  withProjectBuildGradle,
} = require('@expo/config-plugins');
const { addImports } = require('@expo/config-plugins/build/android/codeMod');
const { mergeContents } = require('@expo/config-plugins/build/utils/generateCode');

const CAST_FRAMEWORK_VERSION = '21.5.0';

// ─── Android ─────────────────────────────────────────────────────────────────

function addCastFrameworkVersion(src) {
  return mergeContents({
    tag: 'video-one-google-cast-version',
    src,
    newSrc: `  ext {\n    castFrameworkVersion = "${CAST_FRAMEWORK_VERSION}"\n  }`,
    anchor: /buildscript\s*\{/,
    offset: 1,
    comment: '//',
  }).contents;
}

function addCastPermissions(androidManifest) {
  const { manifest } = androidManifest;
  const permissions = manifest['uses-permission'] || [];

  const required = [
    'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE',
    'android.permission.ACCESS_WIFI_STATE',
  ];

  for (const perm of required) {
    const already = permissions.some(
      (p) => p.$['android:name'] === perm
    );
    if (!already) {
      permissions.push({ $: { 'android:name': perm } });
    }
  }

  manifest['uses-permission'] = permissions;
  return androidManifest;
}

function addCastOptionsProvider(androidManifest) {
  const { manifest } = androidManifest;
  const app = manifest.application?.[0];
  if (!app) return androidManifest;

  // Ensure meta-data array exists
  app['meta-data'] = app['meta-data'] || [];

  const PROVIDER_KEY = 'com.google.android.gms.cast.framework.OPTIONS_PROVIDER_CLASS_NAME';
  const alreadyAdded = app['meta-data'].some(
    (m) => m.$['android:name'] === PROVIDER_KEY
  );

  if (!alreadyAdded) {
    app['meta-data'].push({
      $: {
        'android:name': PROVIDER_KEY,
        'android:value': 'com.byteplus.videoone.rn.CastOptionsProvider',
      },
    });
  }

  return androidManifest;
}

function addCastContextInitialization(src, language) {
  const withImport = addImports(
    src,
    ['com.reactnative.googlecast.api.RNGCCastContext'],
    language === 'java',
  );

  return mergeContents({
    tag: 'video-one-google-cast-onCreate',
    src: withImport,
    newSrc: '    RNGCCastContext.getSharedInstance(this)',
    anchor: /super\.onCreate\(\w+\)/,
    offset: 1,
    comment: '//',
  }).contents;
}

// ─── iOS ─────────────────────────────────────────────────────────────────────

/**
 * Add NSBonjourServices for local network discovery (required for Cast on iOS
 * if you ever enable it; harmless for AirPlay-only builds).
 * Also add NSLocalNetworkUsageDescription for iOS 14+.
 */
function addAirPlayInfoPlist(config) {
  return withInfoPlist(config, (config) => {
    // Needed for AirPlay route picker and local-network device discovery
    if (!config.modResults.NSLocalNetworkUsageDescription) {
      config.modResults.NSLocalNetworkUsageDescription =
        'This app needs local network access to discover AirPlay and Cast devices.';
    }

    // Required by iOS 14+ for Bonjour-based device discovery
    const bonjourServices = config.modResults.NSBonjourServices || [];
    const requiredServices = [
      '_airplay._tcp', // AirPlay device discovery (iOS)
      '_googlecast._tcp',
      '_CC1AD845._googlecast._tcp', // default Cast receiver (see CastOptionsProvider)
      '_expo._tcp', // expo-dev-client / Metro discovery
    ];
    for (const service of requiredServices) {
      if (!bonjourServices.includes(service)) {
        bonjourServices.push(service);
      }
    }
    config.modResults.NSBonjourServices = bonjourServices;

    return config;
  });
}

// ─── Compose ─────────────────────────────────────────────────────────────────

const withGoogleCast = (config) => {
  config = withProjectBuildGradle(config, (config) => {
    config.modResults.contents = addCastFrameworkVersion(config.modResults.contents);
    return config;
  });

  // Android manifest changes
  config = withAndroidManifest(config, (config) => {
    config.modResults = addCastPermissions(config.modResults);
    config.modResults = addCastOptionsProvider(config.modResults);
    return config;
  });

  config = withMainActivity(config, (config) => {
    config.modResults.contents = addCastContextInitialization(
      config.modResults.contents,
      config.modResults.language,
    );
    return config;
  });

  // iOS Info.plist changes
  config = addAirPlayInfoPlist(config);

  return config;
};

module.exports = withGoogleCast;
