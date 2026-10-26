// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

/**
 * CastButton — platform-aware screen-casting trigger
 *
 * iOS     : AVRoutePickerView via the app's native AirPlayRoutePickerView.
 * Android : Google Cast via react-native-google-cast.
 */

import React, { useCallback, useEffect, useRef } from 'react';
import {
  Animated,
  Easing,
  Platform,
  StyleSheet,
  Pressable,
  TouchableOpacity,
  View,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import AirPlayRoutePickerView from './AirPlayRoutePickerView';
import SvgIcon from '../ui/SvgIcon';
import { AirPlayRelay } from './AirPlayRelay';
import { useCast, type CastController } from '../../hooks/useCast';

// ─── Types ───────────────────────────────────────────────────────────────────

interface CastButtonProps {
  castController?: CastController;
  videoUrl?: string;
  currentTime?: number;
  title?: string;
  coverUrl?: string;
  size?: number;
  color?: string;
  activeColor?: string;
  style?: StyleProp<ViewStyle>;
  onCastStart?: () => void;
  onCastStop?: () => void;
}

type AndroidCastButtonProps = CastButtonProps & {
  castController: CastController;
};

/** Apple HIG minimum touch target; AVRoutePickerView needs room to draw its icon. */
const IOS_MIN_TOUCH_SIZE = 44;

// ─── iOS — native AirPlay button ─────────────────────────────────────────────

const IOSCastButton: React.FC<CastButtonProps> = ({
  size = 24,
  color = '#FFFFFF',
  activeColor = '#5B8CFF',
  style,
}) => {
  const touchSize = Math.max(size, IOS_MIN_TOUCH_SIZE);

  const handleWillPresentRoutes = useCallback(() => {
    AirPlayRelay.beginRouteSelection().catch((error) => {
      console.warn('[CastButton] Failed to begin AirPlay route selection:', error);
    });
  }, []);

  const handleDidEndPresentingRoutes = useCallback(() => {
    AirPlayRelay.endRouteSelection().catch((error) => {
      console.warn('[CastButton] Failed to finish AirPlay route selection:', error);
    });
  }, []);

  return (
    <View
      style={[styles.iosButton, { width: touchSize, height: touchSize }, style]}
      accessibilityRole="button"
      accessibilityLabel="AirPlay"
    >
      <AirPlayRoutePickerView
        style={{ width: touchSize, height: touchSize }}
        tintColor={color}
        activeTintColor={activeColor}
        prioritizesVideoDevices
        onWillPresentRoutes={handleWillPresentRoutes}
        onDidEndPresentingRoutes={handleDidEndPresentingRoutes}
      />
    </View>
  );
};

// ─── Android — Google Cast button ────────────────────────────────────────────

const AndroidCastButton: React.FC<AndroidCastButtonProps> = ({
  castController,
  videoUrl,
  currentTime = 0,
  title,
  coverUrl,
  size = 24,
  color = '#FFFFFF',
  activeColor = '#5B8CFF',
  style,
  onCastStart,
  onCastStop,
}) => {
  const {
    isConnecting,
    isConnected,
    isCasting,
    deviceName,
    showCastPicker,
    startCasting,
    stopCasting,
  } = castController;
  const shouldLoadAfterConnectRef = useRef(false);

  let NativeCastButton: React.ComponentType<{
    style?: ViewStyle;
    tintColor?: string;
    pointerEvents?: 'none' | 'auto' | 'box-none' | 'box-only';
  }> | null = null;
  try {
    NativeCastButton = require('react-native-google-cast').CastButton;
  } catch {
    NativeCastButton = null;
  }

  const pulseAnim = useRef(new Animated.Value(1)).current;
  const pulseLoopRef = useRef<Animated.CompositeAnimation | null>(null);

  useEffect(() => {
    if (isConnecting) {
      pulseLoopRef.current = Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 0.4,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
      );
      pulseLoopRef.current.start();
    } else {
      pulseLoopRef.current?.stop();
      pulseAnim.setValue(1);
    }
  }, [isConnecting, pulseAnim]);

  const prevCasting = useRef(false);
  useEffect(() => {
    if (isCasting && !prevCasting.current) {
      onCastStart?.();
    } else if (!isCasting && prevCasting.current) {
      onCastStop?.();
    }
    prevCasting.current = isCasting;
  }, [isCasting, onCastStart, onCastStop]);

  useEffect(() => {
    if (
      !shouldLoadAfterConnectRef.current ||
      !isConnected ||
      isCasting ||
      !videoUrl
    ) {
      return;
    }

    shouldLoadAfterConnectRef.current = false;
    startCasting(videoUrl, currentTime, { title, coverUrl });
  }, [
    isConnected,
    isCasting,
    videoUrl,
    currentTime,
    title,
    coverUrl,
    startCasting,
  ]);

  const handlePress = useCallback(async () => {
    if (isCasting) {
      shouldLoadAfterConnectRef.current = false;
      stopCasting();
      return;
    }
    if (!videoUrl) {
      console.warn('[CastButton] Missing video URL for casting');
      return;
    }
    if (!isConnected) {
      shouldLoadAfterConnectRef.current = true;
      showCastPicker();
      return;
    }
    await startCasting(videoUrl, currentTime, { title, coverUrl });
  }, [
    isCasting,
    isConnected,
    videoUrl,
    currentTime,
    title,
    coverUrl,
    showCastPicker,
    startCasting,
    stopCasting,
  ]);

  const iconColor = isConnected || isCasting ? activeColor : color;

  if (NativeCastButton) {
    return (
      <Pressable
        onPress={handlePress}
        hitSlop={8}
        style={[styles.androidButton, { width: size, height: size }, style]}
        accessibilityRole="button"
        accessibilityLabel="Cast to a device"
      >
        <NativeCastButton
          pointerEvents="none"
          style={StyleSheet.absoluteFill}
          tintColor={iconColor}
        />
        {isConnecting && (
          <Animated.View
            pointerEvents="none"
            style={[StyleSheet.absoluteFill, { opacity: pulseAnim }]}
          />
        )}
      </Pressable>
    );
  }

  return (
    <TouchableOpacity
      onPress={handlePress}
      activeOpacity={0.7}
      style={[styles.androidButton, style]}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      accessibilityLabel={
        isCasting
          ? `Stop casting to ${deviceName ?? 'device'}`
          : 'Cast to a device'
      }
      accessibilityRole="button"
    >
      <Animated.View style={{ opacity: pulseAnim }}>
        <CastIcon size={size} color={iconColor} />
      </Animated.View>
    </TouchableOpacity>
  );
};

const UncontrolledAndroidCastButton: React.FC<CastButtonProps> = (props) => {
  const castController = useCast();
  return <AndroidCastButton {...props} castController={castController} />;
};

const CastIcon: React.FC<{ size: number; color: string }> = ({ size, color }) => (
  <SvgIcon name="cast" width={size} height={size} color={color} />
);

const CastButton: React.FC<CastButtonProps> = (props) => {
  if (Platform.OS === 'ios') {
    return <IOSCastButton {...props} />;
  }
  if (props.castController) {
    return (
      <AndroidCastButton
        {...props}
        castController={props.castController}
      />
    );
  }
  return <UncontrolledAndroidCastButton {...props} />;
};

const styles = StyleSheet.create({
  iosButton: {
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 999,
    elevation: 999,
    overflow: 'visible',
  },
  androidButton: {
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 999,
    elevation: 999,
    padding: 4,
  },
  fallback: {
    justifyContent: 'center',
    alignItems: 'center',
    opacity: 0.5,
  },
  fallbackIcon: {
    fontSize: 10,
    fontWeight: '600',
  },
});

export default CastButton;
