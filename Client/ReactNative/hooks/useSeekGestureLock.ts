// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { useCallback, useLayoutEffect, useRef, useState } from "react";
import { Platform } from "react-native";
import { useNavigation, usePreventRemove } from "@react-navigation/native";

export function useSeekGestureLock(otherGestureBlocked = false) {
  const navigation = useNavigation();
  const [isSeeking, setIsSeeking] = useState(false);
  const blockedRef = useRef(otherGestureBlocked);
  blockedRef.current = otherGestureBlocked;

  const onSeekingChange = useCallback((seeking: boolean) => {
    // Apply immediately on touch grant, ahead of the next page render.
    if (Platform.OS === "ios") {
      navigation.setOptions({ gestureEnabled: !seeking && !blockedRef.current });
    }
    setIsSeeking(seeking);
  }, [navigation]);

  useLayoutEffect(() => {
    if (Platform.OS === "ios") {
      navigation.setOptions({ gestureEnabled: !isSeeking && !otherGestureBlocked });
    }
  }, [navigation, isSeeking, otherGestureBlocked]);

  // Cancel a dismissal even if its native recognizer began before the options update.
  usePreventRemove(isSeeking, () => {});

  return { isSeeking, onSeekingChange };
}
