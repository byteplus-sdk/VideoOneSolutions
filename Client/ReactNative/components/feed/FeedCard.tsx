// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState } from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { Image } from "expo-image";
import { FeedItem } from "../../types/drama";

interface FeedCardProps {
  feedItem: FeedItem;
  onPress: (feedItem: FeedItem) => void;
}

const FeedCard: React.FC<FeedCardProps> = ({ feedItem, onPress }) => {
  const { drama_meta, video_meta } = feedItem;
  const [isClosed, setIsClosed] = useState(false);

  // format play times
  const formatPlayTimes = (times: number) => {
    if (times >= 10000) {
      return `${(times / 10000).toFixed(1)}w`;
    }
    return times.toLocaleString();
  };

  // handle close button click
  const handleClose = () => {
    setIsClosed(true);
  };

  // if card is closed, don't render any content
  if (isClosed) {
    return null;
  }

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        {/* Close button */}
        <TouchableOpacity
          style={styles.closeButton}
          activeOpacity={0.7}
          onPress={handleClose}
        >
          <Image
            source={require("@/assets/images/close.png")}
            style={styles.closeIcon}
          />
        </TouchableOpacity>

        {/* Card content */}
        <View style={styles.cardContent}>
          {/* Top content area */}
          <TouchableOpacity
            style={styles.topContent}
            onPress={() => onPress(feedItem)}
            activeOpacity={0.8}
          >
            {/* Left thumbnail */}
            <Image
              source={{ uri: drama_meta.drama_cover_url }}
              style={styles.thumbnail}
            />

            {/* Middle content area */}
            <View style={styles.contentArea}>
              <View style={styles.titleContainer}>
                <Text style={styles.title} numberOfLines={1}>
                  {video_meta.caption || drama_meta.drama_title}
                </Text>
              </View>

              {/* Hot info */}
              <View style={styles.statsContainer}>
                <Image
                  source={require("@/assets/minidrama/common/fire.png")}
                  style={styles.fireIcon}
                />
                <Text style={styles.statsText}>
                  {formatPlayTimes(drama_meta.drama_play_times)}
                </Text>
              </View>
            </View>
          </TouchableOpacity>

          {/* Bottom play button */}
          <TouchableOpacity
            style={styles.playButton}
            onPress={() => onPress(feedItem)}
            activeOpacity={0.8}
          >
            <Text style={styles.playButtonText}>Play Now</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: "absolute",
    bottom: 52,
    left: 0,
    zIndex: 100,
    paddingHorizontal: 10,
    paddingBottom: 16,
  },
  card: {
    backgroundColor: "rgba(255, 255, 255, 0.2)",
    borderRadius: 12,
    width: 275,
    height: 144,
    position: "relative",
    overflow: "hidden",
  },
  closeButton: {
    position: "absolute",
    top: 4,
    right: 8,
    width: 32,
    height: 32,
    justifyContent: "center",
    alignItems: "center",
    zIndex: 10,
  },
  closeIcon: {
    width: 10,
    height: 10,
    tintColor: "rgba(255, 255, 255, 0.8)",
  },
  cardContent: {
    flex: 1,
    flexDirection: "column",
    paddingHorizontal: 12,
    paddingTop: 16,
    paddingBottom: 12,
  },
  topContent: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
    marginBottom: 12,
  },
  thumbnail: {
    width: 36,
    height: 48,
    borderRadius: 6,
    marginRight: 8,
  },
  contentArea: {
    flex: 1,
    justifyContent: "center",
  },
  titleContainer: {
    marginBottom: 4,
  },
  title: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "500",
    lineHeight: 24,
  },
  statsContainer: {
    flexDirection: "row",
    alignItems: "center",
    opacity: 0.8,
  },
  fireIcon: {
    width: 12,
    height: 12,
    marginRight: 4,
    tintColor: "#FFFFFF",
  },
  statsText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "400",
    lineHeight: 20,
  },
  playButton: {
    backgroundColor: "#FE2C55",
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    width: "100%",
    alignItems: "center",
    justifyContent: "center",
  },
  playButtonText: {
    color: "#FFFFFF",
    fontSize: 15,
    fontWeight: "500",
    lineHeight: 21,
  },
});

export default FeedCard;
