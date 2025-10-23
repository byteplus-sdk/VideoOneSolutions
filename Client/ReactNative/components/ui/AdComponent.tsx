// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useRef, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  Modal,
} from "react-native";
import { Image } from "expo-image";
import { getImageAsset } from "../../utils/imageUtils";
import { SafeAreaView } from "react-native-safe-area-context";

const { width: screenWidth, height: screenHeight } = Dimensions.get("window");

interface AdComponentProps {
  visible: boolean;
  onClose: () => void;
  onAdComplete: () => void;
  duration?: number; // Ad duration, default 10 seconds
}

const AdComponent: React.FC<AdComponentProps> = ({
  visible,
  onClose,
  onAdComplete,
  duration = 10,
}) => {
  const [count, setCount] = useState(duration);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const onAdCompleteRef = useRef(onAdComplete);

  // Update ref when onAdComplete changes
  useEffect(() => {
    onAdCompleteRef.current = onAdComplete;
  }, [onAdComplete]);

  useEffect(() => {
    if (visible) {
      // Clear previous timer
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }

      // Reset countdown
      setCount(duration);

      // Start countdown
      timerRef.current = setInterval(() => {
        setCount((prevCount) => {
          if (prevCount <= 1) {
            // Countdown finished, delay unlock to avoid state updates during rendering
            setTimeout(() => {
              onAdCompleteRef.current();
            }, 0);
            return 0;
          }
          return prevCount - 1;
        });
      }, 1000);
    } else {
      // Clear timer when not visible
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    }

    // Cleanup function
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    };
  }, [visible, duration]); // Remove onAdComplete dependency

  const handleClose = () => {
    if (count <= 0) {
      onClose();
    }
  };

  if (!visible) return null;

  return (
    <Modal
      visible={visible}
      transparent={true}
      animationType="fade"
      onRequestClose={handleClose}
    >
      <View style={styles.overlay}>
        <SafeAreaView style={styles.container}>
          <View style={styles.controlBar}>
            <View style={styles.adLabel}>
              <Text style={styles.adText}>Ad</Text>
              <Text style={styles.separator}>|</Text>
              <TouchableOpacity style={styles.muteButton}>
                <Image
                  source={getImageAsset("common/mute")}
                  style={styles.muteIcon}
                />
              </TouchableOpacity>
            </View>

            {count > 0 ? (
              <View style={styles.countdown}>
                <Text style={styles.countdownText}>{count}s</Text>
              </View>
            ) : (
              <TouchableOpacity
                style={styles.closeButton}
                onPress={handleClose}
              >
                <Text style={styles.closeIcon}>✕</Text>
              </TouchableOpacity>
            )}
          </View>

          {/* Ad content area */}
          <View style={styles.adContent}>
            <Image
              source={{
                uri: "https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/cocacola.gif",
              }}
              style={styles.adImage}
            />
          </View>
        </SafeAreaView>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.9)",
    justifyContent: "center",
    alignItems: "center",
  },
  container: {
    width: screenWidth,
    height: screenHeight,
    justifyContent: "center",
    alignItems: "center",
  },
  controlBar: {
    position: "absolute",
    top: 50,
    left: 20,
    right: 20,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    zIndex: 10,
  },
  adLabel: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0, 0, 0, 0.6)",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  adText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "600",
  },
  separator: {
    color: "#FFFFFF",
    fontSize: 14,
    marginHorizontal: 8,
  },
  muteButton: {
    padding: 4,
  },
  muteIcon: {
    width: 16,
    height: 16,
  },
  countdown: {
    backgroundColor: "rgba(0, 0, 0, 0.6)",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  countdownText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "600",
  },
  closeButton: {
    backgroundColor: "rgba(0, 0, 0, 0.6)",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
  },
  closeIcon: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
  adContent: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    width: "100%",
  },
  adImage: {
    width: screenWidth,
    height: screenHeight * 0.6,
  },
});

export default AdComponent;
