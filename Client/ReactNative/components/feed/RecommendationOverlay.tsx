// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  FlatList,
  Modal,
  Animated,
} from "react-native";
import { Image } from "expo-image";
import { router } from "expo-router";
import { FeedItem } from "../../types/drama";

const { height: screenHeight } = Dimensions.get("window");

interface RecommendationOverlayProps {
  visible: boolean;
  onClose: () => void;
  feedItems: FeedItem[];
  currentVideoIndex?: number; // Currently playing video index
}

const RecommendationOverlay: React.FC<RecommendationOverlayProps> = ({
  visible,
  onClose,
  feedItems,
  currentVideoIndex = 0,
}) => {
  // Use all feedItems data
  const recommendations = feedItems;

  // Animation values
  const slideAnim = useRef(new Animated.Value(screenHeight)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;

  // FlatList reference
  const flatListRef = useRef<FlatList>(null);

  // Handle show/hide animation
  useEffect(() => {
    if (visible) {
      // Show animation: slide in from bottom
      Animated.parallel([
        Animated.timing(slideAnim, {
          toValue: 0,
          duration: 300,
          useNativeDriver: true,
        }),
        Animated.timing(opacityAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]).start(() => {
        // After animation completes, scroll to currently playing item
        setTimeout(() => {
          flatListRef.current?.scrollToIndex({
            index: currentVideoIndex,
            animated: true,
            viewPosition: 0, // Scroll to top
          });
        }, 100); // Slight delay to ensure FlatList is rendered
      });
    } else {
      // Hide animation: slide to bottom
      Animated.parallel([
        Animated.timing(slideAnim, {
          toValue: screenHeight,
          duration: 250,
          useNativeDriver: true,
        }),
        Animated.timing(opacityAnim, {
          toValue: 0,
          duration: 250,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [visible, slideAnim, opacityAnim, currentVideoIndex]);

  const handleRecommendationPress = (feedItem: FeedItem) => {
    const { drama_meta, video_meta } = feedItem;

    // Close recommendation list
    onClose();

    // Navigate to drama_player page
    router.push({
      pathname: "/drama_player",
      params: {
        dramaId: drama_meta.drama_id,
        dramaTitle: drama_meta.drama_title,
        dramaCoverUrl: drama_meta.drama_cover_url,
        episodeOrder: video_meta.order.toString(),
        currentTime: "0",
      },
    });
  };

  // Format play count
  const formatPlayTimes = (times: number) => {
    if (times >= 10000) {
      return `${(times / 10000).toFixed(1)}w`;
    }
    return times.toLocaleString();
  };

  // Format duration
  const formatDuration = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
  };

  const renderRecommendationItem = ({
    item,
    index,
  }: {
    item: FeedItem;
    index: number;
  }) => {
    const { drama_meta, video_meta } = item;
    const isCurrentVideo = index === currentVideoIndex;

    return (
      <TouchableOpacity
        style={[
          styles.recommendationItem,
          isCurrentVideo && styles.currentVideoItem, // Highlight currently playing video
        ]}
        onPress={() => handleRecommendationPress(item)}
        activeOpacity={0.8}
      >
        {/* Thumbnail container */}
        <View style={styles.thumbnailContainer}>
          <Image
            source={{ uri: drama_meta.drama_cover_url }}
            style={styles.thumbnail}
          />
        </View>

        {/* Content area */}
        <View style={styles.itemContent}>
          <Text
            style={[
              styles.title,
              isCurrentVideo && styles.currentVideoTitle, // Use black text when highlighted
            ]}
            numberOfLines={2}
          >
            {video_meta.caption || drama_meta.drama_title}
          </Text>

          {/* Duration and popularity info */}
          <View style={styles.metadataContainer}>
            <Text
              style={[
                styles.duration,
                isCurrentVideo && styles.currentVideoText, // Use black text when highlighted
              ]}
            >
              {formatDuration(video_meta.duration)}
            </Text>

            <Image
              source={require("@/assets/minidrama/common/fire.png")}
              style={[
                styles.fireIcon,
                isCurrentVideo && styles.currentVideoIcon, // Use black icon when highlighted
              ]}
            />
            <Text
              style={[
                styles.statsText,
                isCurrentVideo && styles.currentVideoText, // Use black text when highlighted
              ]}
            >
              {formatPlayTimes(drama_meta.drama_play_times)}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  return (
    <Modal
      visible={visible}
      animationType="none"
      transparent={true}
      onRequestClose={onClose}
    >
      <Animated.View style={[styles.overlay, { opacity: opacityAnim }]}>
        {/* Semi-transparent background */}
        <TouchableOpacity
          style={styles.background}
          activeOpacity={1}
          onPress={onClose}
        />

        {/* Recommendation list container */}
        <Animated.View
          style={[
            styles.container,
            {
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          {/* Top title bar */}
          <View style={styles.header}>
            <TouchableOpacity onPress={onClose} style={styles.backButton}>
              <Image
                source={require("@/assets/images/back_arrow.png")}
                style={styles.backIcon}
              />
            </TouchableOpacity>

            <View style={styles.titleContainer}>
              <Image
                source={require("@/assets/images/recommend.png")}
                style={styles.titleIcon}
              />
              <Text style={styles.headerTitle}>Recommend for you</Text>
            </View>

            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <Image
                source={require("@/assets/images/close.png")}
                style={styles.closeIcon}
              />
            </TouchableOpacity>
          </View>

          {/* Recommendation list */}
          <FlatList
            ref={flatListRef}
            data={recommendations}
            renderItem={renderRecommendationItem}
            keyExtractor={(item) => item.video_meta.vid}
            contentContainerStyle={styles.listContainer}
            showsVerticalScrollIndicator={false}
            onScrollToIndexFailed={(info) => {
              // Handle scroll failure cases
              console.warn("Scroll to index failed:", info);
              // Use scrollToOffset as fallback
              setTimeout(() => {
                flatListRef.current?.scrollToOffset({
                  offset: info.index * 100, // Estimate height of each item
                  animated: true,
                });
              }, 100);
            }}
          />
        </Animated.View>
      </Animated.View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
  },
  background: {
    flex: 1,
  },
  container: {
    position: "absolute",
    bottom: 0, // Start from bottom
    left: 0,
    right: 0,
    height: screenHeight * 0.8, // Limit to 80% of screen height
    backgroundColor: "rgba(0, 0, 0, 0.8)",
    borderTopLeftRadius: 20, // Top left corner radius
    borderTopRightRadius: 20, // Top right corner radius
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 10,
    borderBottomWidth: 1,
    borderBottomColor: "rgba(255, 255, 255, 0.1)",
  },
  backButton: {
    width: 32,
    height: 32,
    justifyContent: "center",
    alignItems: "center",
  },
  backIcon: {
    width: 20,
    height: 20,
    tintColor: "#FFFFFF",
  },
  titleContainer: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
    justifyContent: "center",
  },
  titleIcon: {
    width: 16,
    height: 16,
    marginRight: 8,
    tintColor: "#FFFFFF",
  },
  headerTitle: {
    color: "#FFFFFF",
    fontSize: 18,
    fontWeight: "600",
  },
  closeButton: {
    width: 32,
    height: 32,
    justifyContent: "center",
    alignItems: "center",
  },
  closeIcon: {
    width: 16,
    height: 16,
    tintColor: "#FFFFFF",
  },
  listContainer: {
    padding: 20,
  },
  recommendationItem: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 16,
    paddingVertical: 8,
  },
  currentVideoItem: {
    backgroundColor: "rgba(255, 255, 255, 0.12)", // Semi-transparent white background
    marginHorizontal: -4, // Slightly expand width
  },
  thumbnailContainer: {
    position: "relative",
    marginRight: 12,
  },
  thumbnail: {
    width: 60,
    height: 80,
    borderRadius: 8,
  },
  playIconContainer: {
    position: "absolute",
    bottom: 4,
    right: 4,
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: "rgba(0, 0, 0, 0.7)",
    justifyContent: "center",
    alignItems: "center",
  },
  playIcon: {
    width: 16,
    height: 16,
    tintColor: "#FFFFFF",
  },
  itemContent: {
    flex: 1,
    justifyContent: "center",
  },
  title: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "500",
    lineHeight: 22,
    marginBottom: 8,
  },
  currentVideoTitle: {
    color: "#FFFFFF", // Keep white text when highlighted
  },
  currentVideoText: {
    color: "#FFFFFF", // Keep white text when highlighted
  },
  currentVideoIcon: {
    tintColor: "#FFFFFF", // Keep white icon when highlighted
  },
  metadataContainer: {
    flexDirection: "row",
    alignItems: "center",
  },
  duration: {
    color: "rgba(255, 255, 255, 0.7)",
    fontSize: 14,
    fontWeight: "400",
    marginRight: 8,
  },
  separator: {
    color: "rgba(255, 255, 255, 0.7)",
    fontSize: 14,
    fontWeight: "400",
    marginHorizontal: 8,
  },
  fireIcon: {
    width: 12,
    height: 12,
    marginRight: 4,
    tintColor: "rgba(255, 255, 255, 0.7)",
  },
  statsText: {
    color: "rgba(255, 255, 255, 0.7)",
    fontSize: 14,
    fontWeight: "400",
  },
});

export default RecommendationOverlay;
