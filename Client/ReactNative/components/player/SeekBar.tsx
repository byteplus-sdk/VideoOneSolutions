// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useCallback, useEffect, useRef, useState } from "react";
import { View, StyleSheet, type GestureResponderEvent } from "react-native";
import * as Progress from "react-native-progress";

interface SeekBarProps {
  duration: number;
  currentTime: number;
  disabled?: boolean;
  onSeek: (time: number) => void;
  onSeekingChange?: (seeking: boolean) => void;
}

export default function SeekBar(props: SeekBarProps) {
  const propsRef = useRef(props);
  propsRef.current = props;
  const widthRef = useRef(0);
  const dragTimeRef = useRef<number | null>(null);
  const [width, setWidth] = useState(0);
  const [previewTime, setPreviewTime] = useState<number | null>(null);
  const enabled = !props.disabled && Number.isFinite(props.duration) && props.duration > 0;

  const cancelDrag = useCallback(() => {
    if (dragTimeRef.current === null) return;
    dragTimeRef.current = null;
    setPreviewTime(null);
    propsRef.current.onSeekingChange?.(false);
  }, []);

  useEffect(() => {
    if (!enabled) cancelDrag();
  }, [enabled, cancelDrag]);

  useEffect(() => () => {
    if (dragTimeRef.current !== null) {
      dragTimeRef.current = null;
      propsRef.current.onSeekingChange?.(false);
    }
  }, []);

  const updateDrag = (event: GestureResponderEvent) => {
    const location = event.nativeEvent.locationX;
    if (!Number.isFinite(location) || widthRef.current <= 0) return;
    const time = Math.max(0, Math.min(1, location / widthRef.current)) * propsRef.current.duration;
    dragTimeRef.current = time;
    setPreviewTime(time);
  };

  const time = previewTime ?? props.currentTime;
  const progress = enabled && Number.isFinite(time)
    ? Math.max(0, Math.min(1, time / props.duration))
    : 0;

  return (
    <View
      style={styles.container}
      onLayout={(event) => {
        widthRef.current = event.nativeEvent.layout.width;
        setWidth(widthRef.current);
      }}
      onStartShouldSetResponder={() => enabled && widthRef.current > 0}
      onMoveShouldSetResponder={() => enabled && widthRef.current > 0}
      onResponderGrant={(event) => {
        if (!enabled || widthRef.current <= 0) return;
        event.stopPropagation();
        updateDrag(event);
        if (dragTimeRef.current !== null) propsRef.current.onSeekingChange?.(true);
      }}
      onResponderMove={(event) => {
        if (dragTimeRef.current === null) return;
        event.stopPropagation();
        updateDrag(event);
      }}
      onResponderRelease={(event) => {
        if (dragTimeRef.current === null) return;
        event.stopPropagation();
        updateDrag(event);
        const targetTime = dragTimeRef.current;
        try {
          if (enabled) propsRef.current.onSeek(targetTime);
        } finally {
          cancelDrag();
        }
      }}
      onResponderTerminationRequest={() => false}
      onResponderTerminate={cancelDrag}
    >
      <View pointerEvents="none">
        <Progress.Bar
          progress={progress}
          width={width}
          height={previewTime === null ? 4 : 6}
          color="rgba(255, 255, 255, 0.8)"
          unfilledColor="rgba(255, 255, 255, 0.3)"
          borderWidth={0}
          borderRadius={3}
          animated={previewTime === null}
          useNativeDriver
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    height: 44,
    width: "100%",
    justifyContent: "center",
    alignItems: "center",
  },
});
