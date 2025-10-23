// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  FlatList,
  Animated,
} from "react-native";
import { Image } from "expo-image";
import { getImageAsset } from "../../utils/imageUtils";
import * as ScreenOrientation from "expo-screen-orientation";
import { DramaEpisode } from "../../types/drama";

interface EpisodeSelectorModalProps {
  visible: boolean;
  onClose: () => void;
  episodes: DramaEpisode[];
  currentEpisodeIndex: number;
  onEpisodeSelect: (index: number) => void;
  dramaTitle: string;
  dramaCoverUrl: string;
  dramaId: string;
  onEpisodeUnlocked?: (
    episodeIndex: number,
    unlockData?: { video_model: string; subtitle_auth_token: string }
  ) => void;
  onUnlockAllPress?: () => void;
}

const EpisodeSelectorModal: React.FC<EpisodeSelectorModalProps> = ({
  visible,
  onClose,
  episodes,
  currentEpisodeIndex,
  onEpisodeSelect,
  dramaTitle,
  dramaCoverUrl,
  dramaId,
  onEpisodeUnlocked,
  onUnlockAllPress,
}) => {
  const [isLandscape, setIsLandscape] = useState(false);
  const slideAnim = useRef(new Animated.Value(0)).current;

  // Check if there are any VIP episodes
  const hasVipEpisodes = episodes.some((episode) => episode.vip === true);

  // Listen to visible changes to control animation
  useEffect(() => {
    if (visible) {
      Animated.timing(slideAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 250,
        useNativeDriver: true,
      }).start();
    }
  }, [visible, slideAnim]);

  // Listen to screen orientation changes
  useEffect(() => {
    const initializeOrientation = async () => {
      try {
        const orientation = await ScreenOrientation.getOrientationAsync();
        const isCurrentlyLandscape =
          orientation === ScreenOrientation.Orientation.LANDSCAPE_LEFT ||
          orientation === ScreenOrientation.Orientation.LANDSCAPE_RIGHT;
        setIsLandscape(isCurrentlyLandscape);
      } catch (error) {
        console.error("Failed to get initial orientation:", error);
      }
    };

    initializeOrientation();

    const subscription = ScreenOrientation.addOrientationChangeListener(
      (event) => {
        const newOrientation = event.orientationInfo.orientation;
        const isCurrentlyLandscape =
          newOrientation === ScreenOrientation.Orientation.LANDSCAPE_LEFT ||
          newOrientation === ScreenOrientation.Orientation.LANDSCAPE_RIGHT;
        setIsLandscape(isCurrentlyLandscape);
      }
    );

    return () => {
      subscription.remove();
    };
  }, []);
  const renderEpisodeItem = ({
    item,
    index,
  }: {
    item: DramaEpisode;
    index: number;
  }) => {
    const isCurrentEpisode = index === currentEpisodeIndex;
    const isLocked = item.vip;

    return (
      <TouchableOpacity
        style={[
          styles.episodeButton,
          isCurrentEpisode && styles.currentEpisodeButton,
        ]}
        onPress={() => onEpisodeSelect(index)}
        activeOpacity={0.7}
      >
        <Text
          style={[
            styles.episodeNumber,
            isCurrentEpisode && styles.currentEpisodeNumber,
          ]}
        >
          {index + 1}
        </Text>
        {isCurrentEpisode && (
          <View style={styles.playIcon}>
            <Image
              source={getImageAsset("common/playing")}
              style={styles.playIconImage}
            />
          </View>
        )}
        {isLocked && (
          <View style={styles.lockIcon}>
            <View style={styles.lockIconBackground} />
            <Image
              source={getImageAsset("common/lock")}
              style={styles.lockIconImage}
            />
          </View>
        )}
      </TouchableOpacity>
    );
  };

  // Calculate animation transform
  const getTransform = () => {
    if (isLandscape) {
      return {
        transform: [
          {
            translateX: slideAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [400, 0],
            }),
          },
        ],
      };
    } else {
      return {
        transform: [
          {
            translateY: slideAnim.interpolate({
              inputRange: [0, 1],
              outputRange: [400, 0],
            }),
          },
        ],
      };
    }
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={onClose}
    >
      <View
        style={[
          styles.modalOverlay,
          isLandscape && styles.landscapeModalOverlay,
        ]}
        onTouchEnd={onClose}
      >
        <Animated.View
          style={[
            styles.modalContainer,
            isLandscape && styles.landscapeModalContainer,
            getTransform(),
          ]}
          onTouchEnd={(e) => e.stopPropagation()}
        >
          {!isLandscape && <View style={styles.dragHandle} />}

          <View
            style={[styles.dramaInfo, isLandscape && styles.landscapeDramaInfo]}
          >
            <Image
              source={{ uri: dramaCoverUrl }}
              style={[
                styles.dramaCover,
                isLandscape && styles.landscapeDramaCover,
              ]}
            />
            <View
              style={[
                styles.dramaDetails,
                isLandscape && styles.landscapeDramaDetails,
              ]}
            >
              <Text
                style={[
                  styles.dramaTitle,
                  isLandscape && styles.landscapeDramaTitle,
                ]}
                numberOfLines={isLandscape ? 2 : 1}
              >
                {dramaTitle}
              </Text>
              <Text
                style={[
                  styles.episodeCount,
                  isLandscape && styles.landscapeEpisodeCount,
                ]}
              >
                All episodes {episodes.length}
              </Text>
            </View>
            {onUnlockAllPress && hasVipEpisodes && (
              <TouchableOpacity
                style={[
                  styles.unlockAllButton,
                  isLandscape && styles.landscapeUnlockAllButton,
                ]}
                onPress={onUnlockAllPress}
                activeOpacity={0.8}
              >
                <Image
                  source={getImageAsset("common/lock_3x")}
                  style={styles.unlockAllIcon}
                />
                <Text style={styles.unlockAllButtonText}>Unlock all</Text>
              </TouchableOpacity>
            )}
          </View>

          <FlatList
            data={episodes}
            renderItem={renderEpisodeItem}
            keyExtractor={(item) => item.vid}
            style={[
              styles.episodeGrid,
              isLandscape && styles.landscapeEpisodeGrid,
            ]}
            numColumns={6}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={[
              styles.episodeGridContent,
              isLandscape && styles.landscapeEpisodeGridContent,
            ]}
          />
        </Animated.View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.2)",
    justifyContent: "flex-end",
  },
  landscapeModalOverlay: {
    justifyContent: "flex-end",
    alignItems: "flex-end",
  },
  modalContainer: {
    backgroundColor: "#000000",
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
  },
  landscapeModalContainer: {
    width: "40%",
    height: "100%",
    borderTopLeftRadius: 20,
    borderTopRightRadius: 0,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 0,
  },
  dragHandle: {
    width: 32,
    height: 4,
    backgroundColor: "rgba(255, 255, 255, 0.1)",
    borderRadius: 4,
    alignSelf: "center",
    marginTop: 6,
    marginBottom: 10,
  },
  dramaInfo: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 8,
    gap: 14,
  },
  landscapeDramaInfo: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 16,
    gap: 12,
    width: "100%",
  },
  dramaCover: {
    width: 44,
    height: 66,
    borderRadius: 4,
  },
  landscapeDramaCover: {
    width: 60,
    height: 90,
    borderRadius: 6,
  },
  dramaDetails: {
    flex: 1,
    gap: 4,
  },
  landscapeDramaDetails: {
    flex: 1,
    gap: 4,
    justifyContent: "center",
    marginRight: 8,
  },
  dramaTitle: {
    color: "#CACBCE",
    fontSize: 16,
    fontWeight: "500",
    lineHeight: 24,
  },
  landscapeDramaTitle: {
    fontSize: 14,
    lineHeight: 20,
    flexWrap: "wrap",
  },
  episodeCount: {
    color: "#76797E",
    fontSize: 14,
    lineHeight: 16,
  },
  landscapeEpisodeCount: {
    fontSize: 12,
    lineHeight: 14,
  },
  unlockAllButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFDD99",
    borderRadius: 4,
    paddingHorizontal: 4,
    paddingVertical: 0,
    height: 32,
    width: 90,
    justifyContent: "center",
    gap: 2,
  },
  landscapeUnlockAllButton: {
    height: 28,
    width: 80,
    paddingHorizontal: 3,
    gap: 1,
    flexShrink: 0,
    backgroundColor: "orange",
  },
  unlockAllIcon: {
    width: 12,
    height: 12,
    tintColor: "#703A17",
  },
  unlockAllButtonText: {
    color: "#703A17",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 24,
  },
  episodeGrid: {
    paddingHorizontal: 16,
  },
  landscapeEpisodeGrid: {
    paddingHorizontal: 12,
  },
  episodeGridContent: {
    paddingBottom: 20,
  },
  landscapeEpisodeGridContent: {
    paddingBottom: 16,
    paddingTop: 8,
  },
  episodeButton: {
    width: 50,
    height: 50,
    backgroundColor: "rgba(152, 154, 159, 0.2)",
    borderRadius: 8,
    justifyContent: "center",
    alignItems: "center",
    margin: 4,
    position: "relative",
  },
  currentEpisodeButton: {
    backgroundColor: "rgba(255, 23, 100, 0.3)",
    borderWidth: 1,
    borderColor: "rgba(255, 23, 100, 0.3)",
  },
  episodeNumber: {
    color: "#CACBCE",
    fontSize: 14,
    fontWeight: "400",
    lineHeight: 20,
    textAlign: "center",
    fontFamily: "PingFang SC",
  },
  currentEpisodeNumber: {
    color: "#FF1764",
  },
  playIcon: {
    position: "absolute",
    top: 4,
    right: 4,
    width: 12,
    height: 12,
  },
  playIconImage: {
    width: 12,
    height: 12,
  },
  lockIcon: {
    position: "absolute",
    top: 0,
    left: 0,
    width: 20,
    height: 13,
  },
  lockIconBackground: {
    width: 20,
    height: 13,
    backgroundColor: "rgb(58,59,61)",
    borderRadius: 0,
    position: "absolute",
    top: 0,
    left: 0,
    borderTopLeftRadius: 8,
    borderBottomRightRadius: 8,
  },
  lockIconImage: {
    width: 10,
    height: 10,
    position: "absolute",
    top: 1,
    left: 5,
  },
});

export default EpisodeSelectorModal;
