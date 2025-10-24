// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React from "react";
import { View, StyleSheet, TouchableOpacity, Text } from "react-native";
import { Image } from "expo-image";
import { DramaChannelMeta } from "../../types/drama";
import { formatNumber } from "../../utils/dramaUtils";
import { getImageAsset } from "../../utils/imageUtils";

interface DramaCoverProps {
  drama: DramaChannelMeta;
  onPress: (drama: DramaChannelMeta) => void;
  width?: number;
  height?: number;
  showPlayCount?: boolean;
  showNewBadge?: boolean;
  showRank?: boolean;
  rank?: number;
  type?: "trending" | "new" | "recommend";
}

const DramaCover: React.FC<DramaCoverProps> = ({
  drama,
  onPress,
  width,
  height,
  showPlayCount = true,
  showNewBadge = true,
  showRank = false,
  rank,
  type = "trending",
}) => {
  const isTopRank = rank && rank <= 3;

  // Trending card: left-right column layout
  if (type === "trending") {
    return (
      <TouchableOpacity
        style={[
          styles.trendingContainer,
          {
            width: width,
            height: height,
          },
        ]}
        onPress={() => onPress(drama)}
        activeOpacity={0.8}
      >
        {/* Left cover */}
        <View style={styles.trendingCoverContainer}>
          <Image
            source={{ uri: drama.dramaCoverUrl }}
            style={styles.trendingCoverImage}
          />

          {/* Rank badge */}
          {showRank && rank && (
            <View
              style={[
                styles.trendingRankBadge,
                isTopRank
                  ? styles.trendingTopRankBadge
                  : styles.trendingNormalRankBadge,
              ]}
            >
              <Text
                style={[
                  styles.trendingRankText,
                  isTopRank
                    ? styles.trendingTopRankText
                    : styles.trendingNormalRankText,
                ]}
              >
                {isTopRank ? `TOP${rank}` : `${rank}`}
              </Text>
            </View>
          )}
        </View>

        {/* Right info area */}
        <View style={styles.trendingInfoContainer}>
          {/* Title */}
          <Text style={styles.trendingTitleText} numberOfLines={2}>
            {drama.dramaTitle}
          </Text>

          {/* Play count */}
          {showPlayCount && (
            <View style={styles.trendingPlayCountContainer}>
              <Image
                source={getImageAsset("drama/playButton")}
                style={styles.trendingPlayIcon}
              />
              <Text style={styles.trendingPlayCountText}>
                {formatNumber(drama.dramaPlayTimes)}
              </Text>
            </View>
          )}
        </View>
      </TouchableOpacity>
    );
  }

  // New Release card: vertical stacked layout
  if (type === "new") {
    return (
      <TouchableOpacity
        style={[
          styles.newContainer,
          {
            width: width,
            height: height,
          },
        ]}
        onPress={() => onPress(drama)}
        activeOpacity={0.8}
      >
        {/* Cover image */}
        <View style={styles.newCoverContainer}>
          <Image
            source={{ uri: drama.dramaCoverUrl }}
            style={styles.newCoverImage}
          />

          {/* New drama label */}
          {showNewBadge && drama.newRelease && (
            <View style={styles.newBadge}>
              <Text style={styles.newBadgeText}>New</Text>
            </View>
          )}

          {/* Play count overlay */}
          {showPlayCount && (
            <View style={styles.newPlayCountOverlay}>
              <Image
                source={getImageAsset("drama/playButton")}
                style={styles.newPlayIcon}
              />
              <Text style={styles.newPlayCountText}>
                {formatNumber(drama.dramaPlayTimes)}
              </Text>
            </View>
          )}
        </View>

        {/* Title */}
        <Text style={styles.newTitleText} numberOfLines={2}>
          {drama.dramaTitle}
        </Text>
      </TouchableOpacity>
    );
  }

  // Recommend card: vertical stacked layout, large size
  if (type === "recommend") {
    return (
      <TouchableOpacity
        style={[
          styles.recommendContainer,
          {
            width: width,
            height: height,
          },
        ]}
        onPress={() => onPress(drama)}
        activeOpacity={0.8}
      >
        {/* Cover image */}
        <View style={styles.recommendCoverContainer}>
          <Image
            source={{ uri: drama.dramaCoverUrl }}
            style={styles.recommendCoverImage}
          />

          {/* Play count overlay */}
          {showPlayCount && (
            <View style={styles.recommendPlayCountOverlay}>
              <Image
                source={getImageAsset("drama/playButton")}
                style={styles.recommendPlayIcon}
              />
              <Text style={styles.recommendPlayCountText}>
                {formatNumber(drama.dramaPlayTimes)}
              </Text>
            </View>
          )}
        </View>

        {/* Title */}
        <Text style={styles.recommendTitleText} numberOfLines={2}>
          {drama.dramaTitle}
        </Text>
      </TouchableOpacity>
    );
  }

  return null;
};

const styles = StyleSheet.create({
  // Trending card styles
  trendingContainer: {
    flexDirection: "row",
    borderRadius: 8,
    overflow: "hidden",
    backgroundColor: "transparent",
  },
  trendingCoverContainer: {
    position: "relative",
    width: "41.3%", // 67.5 / 163.5 ≈ 41.3%
    height: "100%",
    backgroundColor: "transparent",
  },
  trendingCoverImage: {
    width: "100%",
    height: "100%",
    borderRadius: 8,
  },
  trendingRankBadge: {
    position: "absolute",
    top: 0,
    left: 0,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 0,
  },
  trendingTopRankBadge: {
    width: 32,
    height: 16,
    backgroundColor: "#FFDF5A",
  },
  trendingNormalRankBadge: {
    width: 15,
    height: 16,
    backgroundColor: "#FE3BD3",
  },
  trendingRankText: {
    fontSize: 12,
    fontWeight: "400",
    textAlign: "center",
    lineHeight: 12,
  },
  trendingTopRankText: {
    fontFamily: "DINCond-Black",
    color: "#A3442C",
  },
  trendingNormalRankText: {
    fontFamily: "DIN Condensed",
    fontWeight: "700",
    fontSize: 15,
    color: "#FFFFFF",
    lineHeight: 12,
  },
  trendingInfoContainer: {
    flex: 1,
    paddingHorizontal: 8,
    paddingVertical: 4,
    justifyContent: "space-between",
    backgroundColor: "transparent",
  },
  trendingTitleText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 20,
    textAlign: "left",
    flex: 1,
  },
  trendingPlayCountContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 4,
  },
  trendingPlayIcon: {
    width: 12,
    height: 12,
    marginRight: 4,
  },
  trendingPlayCountText: {
    color: "#737A87",
    fontSize: 12,
    fontWeight: "400",
    lineHeight: 16,
  },

  // New Release card styles
  newContainer: {
    borderRadius: 8,
    overflow: "hidden",
    backgroundColor: "transparent",
  },
  newCoverContainer: {
    position: "relative",
    width: "100%",
    height: "73.5%", // 133 / 181 ≈ 73.5%
  },
  newCoverImage: {
    width: "100%",
    height: "100%",
    borderRadius: 8,
  },
  newBadge: {
    position: "absolute",
    top: 0,
    left: 0,
    backgroundColor: "#FE3BD3",
    paddingHorizontal: 3.5,
    paddingVertical: 2.5,
    borderRadius: 8,
    borderTopRightRadius: 0,
  },
  newBadgeText: {
    color: "#FFFFFF",
    fontSize: 10,
    fontWeight: "600",
    lineHeight: 12,
  },
  newPlayCountOverlay: {
    position: "absolute",
    bottom: 4,
    left: 4,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    paddingHorizontal: 4,
    paddingVertical: 2,
    borderRadius: 4,
  },
  newPlayIcon: {
    width: 16,
    height: 16,
    marginRight: 4,
  },
  newPlayCountText: {
    color: "#FFFFFF",
    fontSize: 12,
    fontWeight: "500",
    lineHeight: 17,
  },
  newTitleText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 20,
    textAlign: "left",
    marginTop: 8,
  },

  // Recommend card styles
  recommendContainer: {
    borderRadius: 8,
    overflow: "hidden",
    backgroundColor: "transparent",
  },
  recommendCoverContainer: {
    position: "relative",
    width: "100%",
    height: "81.5%", // 234 / 287 ≈ 81.5%
  },
  recommendCoverImage: {
    width: "100%",
    height: "100%",
    borderRadius: 8,
  },
  recommendPlayCountOverlay: {
    position: "absolute",
    bottom: 5,
    left: 5,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    paddingHorizontal: 5,
    paddingVertical: 3,
    borderRadius: 4,
  },
  recommendPlayIcon: {
    width: 17,
    height: 17,
    marginRight: 5,
  },
  recommendPlayCountText: {
    color: "#FFFFFF",
    fontSize: 13,
    fontWeight: "500",
    lineHeight: 18,
  },
  recommendTitleText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    lineHeight: 20,
    textAlign: "left",
    marginTop: 8,
  },
});

export default DramaCover;
