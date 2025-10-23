// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { Image } from "expo-image";
import { FeedItem } from "../../types/drama";
import { getImageAsset } from "../../utils/imageUtils";

interface InfoPanelProps {
  feedItem: FeedItem;
  onPress: (feedItem: FeedItem) => void;
}

const InfoPanel: React.FC<InfoPanelProps> = ({ feedItem, onPress }) => {
  const { drama_meta, video_meta } = feedItem;

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress(feedItem)}
      activeOpacity={0.8}
    >
      {/* Anchor area */}
      <View style={styles.anchorContainer}>
        <View style={styles.anchorLeft}>
          <View style={styles.playIconContainer}>
            <Image
              source={getImageAsset("common/video")}
              style={styles.playIcon}
            />
          </View>
          <View style={styles.anchorContent}>
            <Text style={styles.categoryText}>Short drama</Text>
            <View style={styles.divider} />
            <Text
              style={styles.dramaTitle}
              numberOfLines={1}
              ellipsizeMode="tail"
            >
              {drama_meta.drama_title}
            </Text>
          </View>
        </View>
      </View>

      {/* User info area */}
      <View style={styles.userInfoContainer}>
        <Text style={styles.usernameText}>@{video_meta.name}</Text>
      </View>

      {/* Content area */}
      <View style={styles.contentInfoContainer}>
        <Text style={styles.contentText} numberOfLines={2}>
          {video_meta.caption || drama_meta.drama_title}
        </Text>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    position: "absolute",
    bottom: 60,
    left: 10,
    right: "20%",
    zIndex: 100,
  },
  anchorContainer: {
    marginBottom: 12,
  },
  anchorLeft: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(40, 40, 40, 0.35)",
    borderRadius: 2,
    paddingHorizontal: 4,
    paddingVertical: 4,
    alignSelf: "flex-start",
  },
  playIconContainer: {
    width: 18,
    height: 18,
    backgroundColor: "#FF1764",
    borderRadius: 2.25,
    justifyContent: "center",
    alignItems: "center",
    marginRight: 4,
  },
  playIcon: {
    width: 16,
    height: 16,
    tintColor: "#FFFFFF",
  },
  anchorContent: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    flex: 1,
  },
  categoryText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 18,
  },
  divider: {
    width: 0.5,
    height: 12,
    backgroundColor: "rgba(255, 255, 255, 0.36)",
  },
  dramaTitle: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 20,
    flex: 1,
  },
  userInfoContainer: {
    marginBottom: 4,
  },
  usernameText: {
    color: "#FFFFFF",
    fontSize: 17,
    fontWeight: "500",
    lineHeight: 20,
  },
  contentInfoContainer: {
    flex: 1,
  },
  contentText: {
    color: "rgba(255, 255, 255, 0.9)",
    fontSize: 15,
    fontWeight: "400",
    lineHeight: 22,
  },
});

export default InfoPanel;
