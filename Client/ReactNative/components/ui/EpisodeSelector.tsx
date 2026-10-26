// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import SvgIcon from "@/components/ui/SvgIcon";
import React from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";

interface EpisodeSelectorProps {
  episodes: any[];
  onPress?: () => void;
}

const EpisodeSelector: React.FC<EpisodeSelectorProps> = ({
  episodes,
  onPress,
}) => {
  return (
    <TouchableOpacity
      style={styles.episodeSelector}
      onPress={onPress}
      activeOpacity={0.8}
    >
      <View style={styles.episodeInfo}>
        <SvgIcon
          name="series"
          style={styles.seriesIcon}
        />
        <View style={styles.episodeTextContainer}>
          <Text style={styles.episodeTitle}>Full Episodes</Text>
          <Text style={styles.episodeCount}>· {episodes.length} videos</Text>
        </View>
      </View>
      <SvgIcon name="chevron-up" style={styles.arrowIcon} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  episodeSelector: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    backgroundColor: "rgba(255, 255, 255, 0.1)",
    borderRadius: 30,
    paddingHorizontal: 16,
    paddingVertical: 8,
    height: 36,
    flex: 1,
    marginRight: 12,
  },
  episodeInfo: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  seriesIcon: {
    width: 20,
    height: 20,
    marginRight: 8,
    tintColor: "rgba(255, 255, 255, 0.7)",
  },
  episodeTextContainer: {
    flexDirection: "row",
    alignItems: "center",
    flex: 1,
  },
  episodeTitle: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "500",
    opacity: 0.7,
  },
  episodeCount: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "500",
    opacity: 0.7,
    marginLeft: 4,
  },
  arrowIcon: {
    width: 16,
    height: 16,
    tintColor: "rgba(255, 255, 255, 0.9)",
  },
});

export default EpisodeSelector;
