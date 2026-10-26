// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useRef } from "react";
import { Animated, Easing, type ImageStyle, type StyleProp } from "react-native";
import Svg, { Rect } from "react-native-svg";

const AnimatedRect = Animated.createAnimatedComponent(Rect);
const BAR_HEIGHTS = [
  [5, 13, 20, 10, 5],
  [18, 10, 5, 13, 18],
  [10, 20, 13, 5, 10],
];

/** Vector equalizer for the episode currently playing. */
export default function PlayingIcon({ style }: { style?: StyleProp<ImageStyle> }) {
  const phase = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const animation = Animated.loop(
      Animated.timing(phase, {
        toValue: 1,
        duration: 1000,
        easing: Easing.linear,
        useNativeDriver: false,
      }),
    );
    animation.start();
    return () => animation.stop();
  }, [phase]);

  return (
    <Svg viewBox="0 0 24 24" style={style} accessible={false} pointerEvents="none">
      {BAR_HEIGHTS.map((heights, index) => (
        <AnimatedRect
          key={index}
          x={3 + index * 7}
          y={phase.interpolate({
            inputRange: [0, 0.25, 0.5, 0.75, 1],
            outputRange: heights.map((height) => 22 - height),
          })}
          width={4}
          height={phase.interpolate({
            inputRange: [0, 0.25, 0.5, 0.75, 1],
            outputRange: heights,
          })}
          rx={1}
          fill="#FE2C55"
        />
      ))}
    </Svg>
  );
}
