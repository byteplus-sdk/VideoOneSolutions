// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  Animated,
  Dimensions,
  Alert,
} from "react-native";
import { Image } from "expo-image";
import { SafeAreaView } from "react-native-safe-area-context";
import { unlockService, AdUnlockRequest } from "../../services/unlockService";
import AdComponent from "../ui/AdComponent";

const { width: screenWidth } = Dimensions.get("window");

interface VipUnlockModalProps {
  visible: boolean;
  onClose: () => void;
  onWatchAd: (
    success: boolean,
    unlockData?: { video_model: string; subtitle_auth_token: string }
  ) => void;
  onUnlockAll: () => void;
  episodeNumber: number;
  dramaId: string;
  episodeVid: string;
}

export const VipUnlockModal: React.FC<VipUnlockModalProps> = ({
  visible,
  onClose,
  onWatchAd,
  onUnlockAll,
  episodeNumber,
  dramaId,
  episodeVid,
}) => {
  const [fadeAnim] = useState(new Animated.Value(0));
  const [scaleAnim] = useState(new Animated.Value(0.8));
  const [loading, setLoading] = useState(false);
  const [showAd, setShowAd] = useState(false);

  useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
        Animated.spring(scaleAnim, {
          toValue: 1,
          tension: 100,
          friction: 8,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 0,
          duration: 200,
          useNativeDriver: true,
        }),
        Animated.timing(scaleAnim, {
          toValue: 0.8,
          duration: 200,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [visible, fadeAnim, scaleAnim]);

  const handleWatchAd = async () => {
    if (loading) return;

    setShowAd(true);
  };

  const handleAdComplete = async () => {
    setShowAd(false);
    setLoading(true);

    try {
      const request: AdUnlockRequest = {
        drama_id: dramaId,
        vid: episodeVid,
      };

      const unlockResponse = await unlockService.unlockEpisodeByAd(request);

      // Unlock successful, pass unlock data
      onWatchAd(true, {
        video_model: unlockResponse.video_model,
        subtitle_auth_token: unlockResponse.subtitle_auth_token,
      });
      onClose();
    } catch (error) {
      console.error("ad unlock failed:", error);
      onWatchAd(false);

      Alert.alert("unlock failed", "ad unlock failed, please try again later");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={onClose}
    >
      <Animated.View style={[styles.modalOverlay, { opacity: fadeAnim }]}>
        <TouchableOpacity
          style={styles.modalBackground}
          activeOpacity={1}
          onPress={onClose}
        />

        <Animated.View
          style={[
            styles.modalContent,
            {
              transform: [{ scale: scaleAnim }],
            },
          ]}
        >
          <View style={styles.illustrationContainer}>
            <Image
              source={require("@/assets/minidrama/common/lock_video.png")}
              style={styles.illustration}
            />
          </View>

          <SafeAreaView style={styles.container} edges={["bottom"]}>
            <View style={styles.contentArea}>
              <View style={styles.titleSection}>
                <Text style={styles.title}>
                  Watch the ad and unlock for free
                </Text>

                <View style={styles.episodeInfo}>
                  <Text style={styles.episodeNumber}>{episodeNumber}</Text>
                  <Text style={styles.episodeLabel}>Episode</Text>
                </View>
              </View>

              <View style={styles.buttonSection}>
                <TouchableOpacity
                  style={[
                    styles.watchAdButton,
                    loading && styles.disabledButton,
                  ]}
                  onPress={handleWatchAd}
                  disabled={loading}
                >
                  <Text style={styles.watchAdButtonText}>
                    {loading ? "Unlocking..." : "Watch now"}
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[
                    styles.unlockAllButton,
                    loading && styles.disabledButton,
                  ]}
                  onPress={onUnlockAll}
                  disabled={loading}
                >
                  <Text style={styles.unlockAllButtonText}>
                    Unlock all episodes
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </SafeAreaView>
        </Animated.View>
      </Animated.View>

      <AdComponent
        visible={showAd}
        onClose={() => setShowAd(false)}
        onAdComplete={handleAdComplete}
        duration={10}
      />
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.7)",
    justifyContent: "center",
    alignItems: "center",
  },
  modalBackground: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  illustrationContainer: {
    alignItems: "center",
    justifyContent: "center",
    width: "100%",
    height: 60,
    marginTop: -30,
    marginBottom: 0,
  },
  illustration: {
    width: 80,
    height: 60,
  },
  modalContent: {
    backgroundColor: "rgba(255, 249, 241, 0.95)",
    borderRadius: 24,
    width: screenWidth * 0.7,
    maxWidth: 280,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 8,
    },
    shadowOpacity: 0.4,
    shadowRadius: 16,
    elevation: 12,
    borderWidth: 1,
    borderColor: "rgba(255, 255, 255, 0.2)",
  },
  container: {
    borderRadius: 24,
    overflow: "hidden",
  },
  contentArea: {
    padding: 24,
    paddingTop: 10,
    gap: 20,
  },
  titleSection: {
    alignItems: "center",
    gap: 12,
  },
  title: {
    fontSize: 16,
    fontWeight: "600",
    color: "#51200C",
    textAlign: "center",
    lineHeight: 24,
    letterSpacing: 0.5,
  },
  episodeInfo: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    height: 65,
    paddingHorizontal: 16,
    paddingVertical: 8,
    gap: 8,
  },
  episodeLabel: {
    fontSize: 14,
    fontWeight: "500",
    color: "#FE2C55",
    lineHeight: 20,
  },
  episodeNumber: {
    fontSize: 32,
    fontWeight: "700",
    color: "#FE2C55",
    lineHeight: 40,
    textAlign: "center",
  },
  buttonSection: {
    gap: 12,
  },
  watchAdButton: {
    backgroundColor: "#FE2C55",
    borderRadius: 16,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: "#FE2C55",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  watchAdButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#FFF9F1",
    textAlign: "center",
    letterSpacing: 0.5,
  },
  unlockAllButton: {
    backgroundColor: "rgba(254, 44, 85, 0.05)",
    borderWidth: 1.5,
    borderColor: "#FE2C55",
    borderRadius: 16,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignItems: "center",
    justifyContent: "center",
  },
  unlockAllButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#FE2C55",
    textAlign: "center",
    letterSpacing: 0.5,
  },
  disabledButton: {
    opacity: 0.6,
  },
});

export default VipUnlockModal;
