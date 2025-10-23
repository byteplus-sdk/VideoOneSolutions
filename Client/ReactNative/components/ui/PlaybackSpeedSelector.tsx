// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect, useCallback } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Modal,
  Animated,
} from "react-native";

interface PlaybackSpeedSelectorProps {
  currentSpeed: number;
  onSpeedChange: (speed: number) => void;
  visible?: boolean; // 外部控制显示状态
  onClose?: () => void; // 关闭回调
}

const SPEED_OPTIONS = [3.0, 2.0, 1.5, 1.0, 0.5];

const PlaybackSpeedSelector: React.FC<PlaybackSpeedSelectorProps> = ({
  currentSpeed,
  onSpeedChange,
  visible: externalVisible,
  onClose,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(300)); // 初始位置在屏幕下方

  const showModal = useCallback(() => {
    setIsVisible(true);
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0, // 滑动到正常位置
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
        toValue: 300, // 滑动到屏幕下方
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start(() => {
      setIsVisible(false);
      onClose?.(); // 调用外部关闭回调
    });
  }, [fadeAnim, slideAnim, onClose]);

  // 监听外部状态变化
  useEffect(() => {
    if (externalVisible !== undefined) {
      if (externalVisible) {
        showModal();
      } else {
        hideModal();
      }
    }
  }, [externalVisible, showModal, hideModal]);

  const handleSpeedSelect = (speed: number) => {
    onSpeedChange(speed);
    hideModal();
  };

  return (
    <>
      {/* 倍速按钮 */}
      <TouchableOpacity onPress={showModal} style={styles.speedButton}>
        <Text style={styles.speedButtonText}>{currentSpeed}X</Text>
      </TouchableOpacity>

      {/* 倍速选择面板 */}
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
            {/* 标题 */}
            <View style={styles.titleContainer}>
              <Text style={styles.title}>Playback speed</Text>
            </View>

            {/* 倍速选项 */}
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
  speedButton: {
    paddingVertical: 4,
    paddingHorizontal: 8,
    minWidth: 38,
    alignItems: "center",
  },
  speedButtonText: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "500",
    opacity: 0.7,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "flex-end",
    alignItems: "center",
    paddingBottom: 50, // 距离底部一些间距
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

export default PlaybackSpeedSelector;
