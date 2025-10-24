// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  Modal,
  Animated,
  Dimensions,
  Alert,
  StyleSheet,
} from "react-native";
import { Image } from "expo-image";
import { getImageAsset } from "../../utils/imageUtils";
import { SafeAreaView } from "react-native-safe-area-context";
import { unlockService, UnlockAllRequest } from "../../services/unlockService";

const { height: screenHeight } = Dimensions.get("window");

interface UnlockMultipleModalProps {
  visible: boolean;
  onClose: () => void;
  onUnlockSuccess: (
    unlockDataList: {
      video_model: string;
      subtitle_auth_token: string;
      vid: string;
    }[]
  ) => void;
  dramaTitle: string;
  dramaCoverUrl?: string;
  allEpisodes: { vid: string; vip: boolean }[];
  dramaId: string;
}

export const UnlockMultipleModal: React.FC<UnlockMultipleModalProps> = ({
  visible,
  onClose,
  onUnlockSuccess,
  dramaTitle,
  dramaCoverUrl,
  allEpisodes,
  dramaId,
}) => {
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(screenHeight));
  const [loading, setLoading] = useState(false);
  const [selectedOption, setSelectedOption] = useState<"partial" | "all">(
    "partial"
  );

  // calculate price
  const vipEpisodes = allEpisodes.filter((episode) => episode.vip);
  const remainingLockedCount = vipEpisodes.length;
  const totalEpisodes = allEpisodes.length;
  const PARTIAL_COUNT = Math.min(10, remainingLockedCount);

  // price model
  const pricePerEpisode = 0.99;
  const originalPerEpisode = 1.99;

  const partialPrice = PARTIAL_COUNT * pricePerEpisode;

  const allPrice = remainingLockedCount * pricePerEpisode;
  const allOriginalPrice = remainingLockedCount * originalPerEpisode;
  const allDiscountPercent = allOriginalPrice
    ? Math.round((1 - allPrice / allOriginalPrice) * 100)
    : 0;

  // animation
  useEffect(() => {
    if (visible) {
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
    } else {
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 0,
          duration: 200,
          useNativeDriver: true,
        }),
        Animated.timing(slideAnim, {
          toValue: screenHeight,
          duration: 200,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [visible, fadeAnim, slideAnim]);

  // unlock selected episodes
  const handlePay = async () => {
    if (loading) return;

    setLoading(true);
    try {
      const unlockVidList =
        selectedOption === "all"
          ? vipEpisodes.map((ep) => ep.vid)
          : vipEpisodes.slice(0, PARTIAL_COUNT).map((ep) => ep.vid);

      const request: UnlockAllRequest = {
        drama_id: dramaId,
        vid_list: unlockVidList,
      };

      const unlockResponse = await unlockService.unlockMultipleEpisodes(
        request
      );

      // unlock success
      onUnlockSuccess(unlockResponse);
      onClose();
    } catch (error) {
      console.error("unlock failed:", error);
      Alert.alert("unlock failed", "unlock failed, please try again later");
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
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          <SafeAreaView style={styles.container} edges={["bottom"]}>
            <View style={styles.header}>
              <Text style={styles.headerTitle}>Unlock episodes</Text>
              <TouchableOpacity style={styles.closeButton} onPress={onClose}>
                <View style={styles.closeIcon}>
                  <Text style={styles.closeIconText}>×</Text>
                </View>
              </TouchableOpacity>
            </View>

            <View style={styles.productInfo}>
              <View style={styles.productCard}>
                <View style={styles.contentInfo}>
                  <View style={styles.content}>
                    <View style={styles.coverContainer}>
                      <View style={styles.coverWrapper}>
                        <Image
                          source={{ uri: dramaCoverUrl || "" }}
                          style={styles.coverImage}
                        />
                      </View>
                    </View>

                    <View style={styles.dramaInfo}>
                      <Text style={styles.dramaTitle} numberOfLines={2}>
                        {dramaTitle}
                      </Text>
                      <Text style={styles.episodeCount}>
                        All episodes {totalEpisodes}
                      </Text>
                    </View>
                  </View>

                  <View style={styles.tipsRow}>
                    <View style={styles.tipItem}>
                      <Image
                        source={getImageAsset("right_icon")}
                        style={styles.tipIconImage}
                      />
                      <Text style={styles.tipText}>Permanent viewing</Text>
                    </View>
                    <View style={styles.tipItem}>
                      <Image
                        source={getImageAsset("not_right_icon")}
                        style={styles.tipIconImage}
                      />
                      <Text style={styles.tipText}>No refund</Text>
                    </View>
                  </View>
                </View>

                {/* Options */}
                <View style={styles.optionsRow}>
                  <TouchableOpacity
                    style={[
                      styles.optionCard,
                      selectedOption === "partial" && styles.optionCardActive,
                    ]}
                    onPress={() => setSelectedOption("partial")}
                    disabled={remainingLockedCount === 0}
                  >
                    <Text style={styles.optionTitle}>
                      {PARTIAL_COUNT} episodes
                    </Text>
                    <View style={styles.optionPriceRow}>
                      <Text style={styles.optionPrice}>
                        USD {partialPrice.toFixed(1)}
                      </Text>
                    </View>
                  </TouchableOpacity>

                  <TouchableOpacity
                    style={[
                      styles.optionCard,
                      selectedOption === "all" && styles.optionCardActive,
                    ]}
                    onPress={() => setSelectedOption("all")}
                    disabled={remainingLockedCount === 0}
                  >
                    <View style={styles.optionAllHeader}>
                      <Text style={styles.optionAllTitle}>All</Text>
                      <Text style={styles.optionAllEpisodes}>episodes</Text>
                      {allDiscountPercent > 0 && (
                        <View style={styles.discountBadge}>
                          <Text style={styles.discountText}>
                            {allDiscountPercent}%
                          </Text>
                        </View>
                      )}
                    </View>
                    <View style={styles.optionPriceRow}>
                      <Text style={styles.optionPrice}>
                        USD {allPrice.toFixed(1)}
                      </Text>
                      {allOriginalPrice > 0 && (
                        <Text style={styles.optionOriginalPrice}>
                          (USD{allOriginalPrice.toFixed(0)})
                        </Text>
                      )}
                    </View>
                  </TouchableOpacity>
                </View>
              </View>
            </View>
            <View style={styles.bottomBar}>
              <TouchableOpacity
                style={[styles.unlockButton, loading && styles.disabledButton]}
                onPress={handlePay}
                disabled={loading || remainingLockedCount === 0}
              >
                <Text style={styles.unlockButtonText}>
                  {loading
                    ? "Processing..."
                    : `Pay for USD ${(selectedOption === "all"
                        ? allPrice
                        : partialPrice
                      ).toFixed(1)}`}
                </Text>
              </TouchableOpacity>
            </View>
          </SafeAreaView>
        </Animated.View>
      </Animated.View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.8)",
    justifyContent: "flex-end",
  },
  modalBackground: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  modalContent: {
    backgroundColor: "#FFF9F1",
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: screenHeight * 0.9,
    minHeight: 450,
    width: "100%",
  },
  container: {
    flex: 1,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#161823",
  },
  closeButton: {
    padding: 8,
  },
  closeIcon: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: "rgba(0, 0, 0, 0.1)",
    alignItems: "center",
    justifyContent: "center",
  },
  closeIconText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#161823",
  },
  productInfo: {
    padding: 16,
  },
  productCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 16,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  contentInfo: {
    marginBottom: 16,
  },
  content: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 12,
  },
  coverContainer: {
    marginRight: 12,
  },
  coverWrapper: {
    width: 60,
    height: 80,
    borderRadius: 8,
    overflow: "hidden",
    backgroundColor: "#F5F5F5",
  },
  coverImage: {
    width: "100%",
    height: "100%",
  },
  dramaInfo: {
    flex: 1,
  },
  dramaTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#161823",
    marginBottom: 4,
  },
  episodeCount: {
    fontSize: 14,
    color: "#8E8E93",
  },
  tipsRow: {
    marginTop: 8,
    flexDirection: "row",
    alignItems: "center",
    gap: 20,
  },
  tipItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  tipIcon: {
    color: "#161823",
    fontSize: 14,
  },
  tipIconImage: {
    width: 18,
    height: 18,
    tintColor: "#161823",
  },
  tipText: {
    color: "#161823",
    fontSize: 14,
  },
  optionsRow: {
    flexDirection: "row",
    gap: 12,
    marginTop: 8,
  },
  optionCard: {
    flex: 1,
    backgroundColor: "#F7F7F7",
    borderRadius: 12,
    paddingVertical: 16,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: "#eee",
  },
  optionCardActive: {
    backgroundColor: "#FFFFFF",
    borderColor: "#FE2C55",
  },
  optionTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#161823",
  },
  optionPriceRow: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 8,
    marginTop: 8,
  },
  optionPrice: {
    fontSize: 18,
    fontWeight: "700",
    color: "#161823",
  },
  optionOriginalPrice: {
    fontSize: 14,
    color: "#8E8E93",
    textDecorationLine: "line-through",
  },
  optionAllHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  optionAllTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#161823",
  },
  optionAllEpisodes: {
    fontSize: 18,
    fontWeight: "600",
    color: "#161823",
  },
  bottomBar: {
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  discountBadge: {
    backgroundColor: "#FE2C55",
    borderRadius: 6,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  discountText: {
    color: "#fff",
    fontSize: 12,
    fontWeight: "700",
  },
  unlockButton: {
    backgroundColor: "#FE2C55",
    borderRadius: 12,
    paddingVertical: 14,
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
    marginTop: 16,
  },
  unlockButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#FFFFFF",
    textAlign: "center",
  },
  disabledButton: {
    opacity: 0.6,
  },
});

export default UnlockMultipleModal;
