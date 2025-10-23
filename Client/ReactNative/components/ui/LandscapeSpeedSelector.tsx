// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useCallback } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Modal,
  Animated,
} from "react-native";
import { Image } from "expo-image";
import { getImageAsset } from "../../utils/imageUtils";

interface LandscapeSpeedSelectorProps {
  currentSpeed: number;
  onSpeedChange: (speed: number) => void;
}

const SPEED_OPTIONS = [2.0, 1.5, 1.25, 1.0, 0.75];

const LandscapeSpeedSelector: React.FC<LandscapeSpeedSelectorProps> = ({
  currentSpeed,
  onSpeedChange,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(300));

  const showModal = useCallback(() => {
    setIsVisible(true);
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }),
    ]).start();
  }, [fadeAnim, slideAnim]);

  const hideModal = useCallback(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 300,
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setIsVisible(false);
    });
  }, [fadeAnim, slideAnim]);

  const handleSpeedSelect = (speed: number) => {
    onSpeedChange(speed);
    hideModal();
  };

  return (
    <>
      {/* Landscape speed button */}
      <TouchableOpacity style={styles.landscapeSpeedButton} onPress={showModal}>
        <Image
          source={getImageAsset("player/v_speed")}
          style={styles.landscapeSpeedIcon}
        />
        <Text style={styles.landscapeSpeedText}>{currentSpeed}×</Text>
      </TouchableOpacity>

      {/* Speed selector modal */}
      <Modal
        visible={isVisible}
        transparent
        animationType="none"
        onRequestClose={hideModal}
      >
        <Animated.View
          style={[styles.modalOverlay, { opacity: fadeAnim }]}
          onTouchEnd={hideModal}
        >
          <Animated.View
            style={[
              styles.modalContent,
              {
                opacity: fadeAnim,
                transform: [{ translateY: slideAnim }],
              },
            ]}
            onTouchEnd={(e) => e.stopPropagation()}
          >
            {/* Title */}
            <View style={styles.titleContainer}>
              <Text style={styles.title}>Playback speed</Text>
            </View>

            {/* Speed options */}
            <View style={styles.optionsContainer}>
              {SPEED_OPTIONS.map((speed) => (
                <TouchableOpacity
                  key={speed}
                  style={[
                    styles.speedOption,
                    currentSpeed === speed && styles.speedOptionActive,
                  ]}
                  onPress={() => handleSpeedSelect(speed)}
                >
                  <Text
                    style={[
                      styles.speedOptionText,
                      currentSpeed === speed && styles.speedOptionTextActive,
                    ]}
                  >
                    {speed}×
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </Animated.View>
        </Animated.View>
      </Modal>
    </>
  );
};

const styles = StyleSheet.create({
  landscapeSpeedButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "transparent",
    gap: 4,
  },
  landscapeSpeedIcon: {
    width: 20,
    height: 20,
    tintColor: "#FFFFFF",
  },
  landscapeSpeedText: {
    color: "#FFFFFF",
    fontSize: 15,
    fontWeight: "600",
    lineHeight: 24,
    textAlign: "center",
    fontFamily: "PingFang SC",
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "flex-end",
    alignItems: "center",
    paddingBottom: 50,
  },
  modalContent: {
    backgroundColor: "#000",
    borderRadius: 8,
    width: "90%",
    maxWidth: 375,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  titleContainer: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: "rgba(255, 255, 255, 0.1)",
  },
  title: {
    color: "rgba(255, 255, 255, 0.9)",
    fontSize: 14,
    fontWeight: "500",
    textAlign: "center",
  },
  optionsContainer: {
    padding: 12,
    gap: 8,
  },
  speedOption: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 2,
    alignItems: "center",
  },
  speedOptionActive: {
    backgroundColor: "rgba(255, 255, 255, 0.12)",
    borderRadius: 8,
  },
  speedOptionText: {
    color: "#fff",
    fontSize: 15,
    fontWeight: "500",
    textAlign: "center",
  },
  speedOptionTextActive: {
    color: "#fff",
  },
});

export default LandscapeSpeedSelector;
