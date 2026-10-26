// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

/**
 * CastStatusBar
 *
 * A slim banner shown at the top of the video player while screen-casting
 * is active. Displays a pulsing "casting" indicator and the name of the
 * target device, plus a "Stop" button to end the session.
 *
 * Usage:
 *   {isCasting && (
 *     <CastStatusBar deviceName={deviceName} onStop={stopCasting} />
 *   )}
 */

import React, { useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

interface CastStatusBarProps {
  /** Friendly name of the cast/AirPlay target device */
  deviceName?: string;
  /** Callback when the user taps "Stop" */
  onStop?: () => void;
}

const CastStatusBar: React.FC<CastStatusBarProps> = ({
  deviceName,
  onStop,
}) => {
  // Pulsing dot animation
  const dotOpacity = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(dotOpacity, {
          toValue: 0.2,
          duration: 800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(dotOpacity, {
          toValue: 1,
          duration: 800,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [dotOpacity]);

  const platformLabel = Platform.OS === 'ios' ? 'AirPlay' : 'Cast';
  const label = deviceName
    ? `${platformLabel}: ${deviceName}`
    : `${platformLabel}ing…`;

  return (
    <View style={styles.container}>
      {/* Pulsing indicator dot */}
      <Animated.View style={[styles.dot, { opacity: dotOpacity }]} />

      {/* Status text */}
      <Text style={styles.label} numberOfLines={1}>
        {label}
      </Text>

      {/* Stop / disconnect button */}
      {onStop && (
        <TouchableOpacity
          onPress={onStop}
          hitSlop={{ top: 8, bottom: 8, left: 12, right: 12 }}
          accessibilityLabel="Stop casting"
          accessibilityRole="button"
        >
          <Text style={styles.stopButton}>Stop</Text>
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 32,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    backgroundColor: 'rgba(0, 0, 0, 0.72)',
    zIndex: 50,
    gap: 8,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#4ADE80', // green-400
  },
  label: {
    flex: 1,
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '500',
  },
  stopButton: {
    color: '#FDA4AF', // rose-300 — visible but not alarming
    fontSize: 12,
    fontWeight: '600',
  },
});

export default CastStatusBar;
