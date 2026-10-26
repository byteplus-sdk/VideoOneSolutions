// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useCallback } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import AirPlayRoutePickerView from './AirPlayRoutePickerView';
import SvgIcon from '../ui/SvgIcon';
import { AirPlayRelay } from './AirPlayRelay';

interface CastActiveOverlayProps {
  deviceName?: string;
  remotePosition?: number;
  onStop: () => void;
}

const formatTime = (seconds?: number) => {
  const value = Math.max(0, Math.floor(seconds ?? 0));
  const minutes = Math.floor(value / 60);
  const remainingSeconds = value % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

const IOSStopCastingButton = () => {
  const handleWillPresentRoutes = useCallback(() => {
    AirPlayRelay.beginStopRouteSelection().catch((error) => {
      console.warn(
        '[CastActiveOverlay] Failed to begin AirPlay stop route selection:',
        error,
      );
    });
  }, []);

  const handleDidEndPresentingRoutes = useCallback(() => {
    AirPlayRelay.endRouteSelection().catch((error) => {
      console.warn(
        '[CastActiveOverlay] Failed to finish AirPlay route selection:',
        error,
      );
    });
  }, []);

  return (
    <View
      style={styles.stopButton}
      accessibilityRole="button"
      accessibilityLabel="Stop casting"
    >
      <Text pointerEvents="none" style={styles.stopButtonText}>
        Stop casting
      </Text>
      <AirPlayRoutePickerView
        style={styles.routePicker}
        tintColor="transparent"
        activeTintColor="transparent"
        prioritizesVideoDevices
        onWillPresentRoutes={handleWillPresentRoutes}
        onDidEndPresentingRoutes={handleDidEndPresentingRoutes}
      />
    </View>
  );
};

const CastActiveOverlay: React.FC<CastActiveOverlayProps> = ({
  deviceName,
  remotePosition,
  onStop,
}) => {
  const label = deviceName ?? (Platform.OS === 'ios' ? 'AirPlay' : 'Cast');

  return (
    <View style={styles.container} pointerEvents="auto">
      <View style={styles.panel}>
        <SvgIcon name="cast" style={styles.iconFrame} color="#7EA2FF" />

        <Text style={styles.title}>Casting to your TV</Text>
        <Text style={styles.device}>{label}</Text>
        <Text style={styles.description}>
          Playback is running on the selected device. Controls on this page are temporarily disabled while casting is active.
        </Text>

        {remotePosition !== undefined && remotePosition > 0 && (
          <Text style={styles.progress}>Casting progress {formatTime(remotePosition)}</Text>
        )}

        {Platform.OS === 'ios' ? (
          <IOSStopCastingButton />
        ) : (
          <TouchableOpacity
            activeOpacity={0.75}
            style={styles.stopButton}
            onPress={onStop}
            accessibilityRole="button"
            accessibilityLabel="Stop casting"
          >
            <Text style={styles.stopButtonText}>Stop casting</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 60,
    elevation: 60,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.68)',
    paddingHorizontal: 28,
  },
  panel: {
    width: '100%',
    maxWidth: 320,
    alignItems: 'center',
    borderRadius: 8,
    backgroundColor: 'rgba(18, 20, 28, 0.94)',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(255, 255, 255, 0.18)',
    paddingHorizontal: 24,
    paddingVertical: 26,
  },
  iconFrame: {
    width: 54,
    height: 40,
    marginBottom: 18,
  },
  title: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '700',
    lineHeight: 26,
  },
  device: {
    color: '#9DB7FF',
    fontSize: 14,
    fontWeight: '600',
    marginTop: 8,
  },
  description: {
    color: 'rgba(255, 255, 255, 0.78)',
    fontSize: 14,
    lineHeight: 20,
    textAlign: 'center',
    marginTop: 12,
  },
  progress: {
    color: 'rgba(255, 255, 255, 0.66)',
    fontSize: 13,
    lineHeight: 18,
    marginTop: 12,
  },
  stopButton: {
    minWidth: 132,
    height: 40,
    borderRadius: 8,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 22,
    paddingHorizontal: 18,
  },
  stopButtonText: {
    color: '#11131A',
    fontSize: 14,
    fontWeight: '700',
  },
  routePicker: {
    ...StyleSheet.absoluteFillObject,
  },
});

export default CastActiveOverlay;
