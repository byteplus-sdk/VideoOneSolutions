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
import { IPlayInfoListItem } from "../../types/drama";

interface LandscapeQualitySelectorProps {
  playInfoList: IPlayInfoListItem[];
  currentQuality: string;
  onQualityChange: (quality: string, playInfo: IPlayInfoListItem) => void;
}

const LandscapeQualitySelector: React.FC<LandscapeQualitySelectorProps> = ({
  playInfoList,
  currentQuality,
  onQualityChange,
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

  const handleQualitySelect = (playInfo: IPlayInfoListItem) => {
    onQualityChange(playInfo.Definition, playInfo);
    hideModal();
  };

  const getCurrentQualityText = () => {
    return currentQuality || "720p";
  };

  return (
    <>
      {/* Landscape quality button */}
      <TouchableOpacity
        style={styles.landscapeQualityButton}
        onPress={showModal}
      >
        <Image
          source={getImageAsset("player/v_quantity")}
          style={styles.landscapeQualityIcon}
        />
        <Text style={styles.landscapeQualityText}>
          {getCurrentQualityText()}
        </Text>
      </TouchableOpacity>

      {/* Quality selector modal */}
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
              <Text style={styles.title}>Video Quality</Text>
            </View>

            {/* Quality options */}
            <View style={styles.optionsContainer}>
              {playInfoList.map((playInfo) => (
                <TouchableOpacity
                  key={playInfo.Definition}
                  style={[
                    styles.qualityOption,
                    currentQuality === playInfo.Definition &&
                      styles.qualityOptionActive,
                  ]}
                  onPress={() => handleQualitySelect(playInfo)}
                >
                  <Text
                    style={[
                      styles.qualityOptionText,
                      currentQuality === playInfo.Definition &&
                        styles.qualityOptionTextActive,
                    ]}
                  >
                    {playInfo.Definition}
                  </Text>
                  <Text style={styles.qualityOptionSubtext}>
                    {playInfo.Width}×{playInfo.Height}
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
  landscapeQualityButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "transparent",
    gap: 4,
  },
  landscapeQualityIcon: {
    width: 20,
    height: 20,
    tintColor: "#FFFFFF",
  },
  landscapeQualityText: {
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
  qualityOption: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 2,
    alignItems: "center",
  },
  qualityOptionActive: {
    backgroundColor: "rgba(255, 255, 255, 0.12)",
    borderRadius: 8,
  },
  qualityOptionText: {
    color: "#fff",
    fontSize: 15,
    fontWeight: "500",
    textAlign: "center",
  },
  qualityOptionTextActive: {
    color: "#fff",
  },
  qualityOptionSubtext: {
    color: "rgba(255, 255, 255, 0.6)",
    fontSize: 12,
    marginTop: 2,
  },
});

export default LandscapeQualitySelector;
