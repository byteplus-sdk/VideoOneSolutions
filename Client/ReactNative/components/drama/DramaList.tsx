// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React from "react";
import { View, Text, StyleSheet, ScrollView, Dimensions } from "react-native";
import { DramaChannelMeta } from "../../types/drama";
import DramaCover from "./DramaCover";

interface DramaListProps {
  data: DramaChannelMeta[];
  onItemPress: (drama: DramaChannelMeta) => void;
  type: "trending" | "new" | "recommend";
}

const { width: screenWidth } = Dimensions.get("window");

const DramaList: React.FC<DramaListProps> = ({ data, onItemPress, type }) => {
  const getTitle = () => {
    switch (type) {
      case "trending":
        return "Trending now 🔥";
      case "new":
        return "New release";
      case "recommend":
        return "Recommended";
      default:
        return "";
    }
  };

  if (data.length === 0) {
    return null;
  }

  // Trending layout: left-right two columns, max 3 per column
  if (type === "trending") {
    const limitedData = data.slice(0, 6); // Max 6 items
    const leftColumn = limitedData.slice(0, 3);
    const rightColumn = limitedData.slice(3, 6);

    // Based on Figma design: card size 163.5×90px
    const cardWidth = (screenWidth - 48) / 2; // Subtract left/right margins and middle spacing
    const cardHeight = cardWidth * (90 / 163.5); // Maintain design aspect ratio

    return (
      <View style={styles.container}>
        <Text style={styles.title}>{getTitle()}</Text>
        <View style={styles.trendingContainer}>
          {/* Left column */}
          <View style={styles.trendingColumn}>
            {leftColumn.map((item, index) => (
              <View key={item.dramaId} style={styles.trendingItem}>
                <DramaCover
                  drama={item}
                  onPress={onItemPress}
                  width={cardWidth}
                  height={cardHeight}
                  showPlayCount={true}
                  showNewBadge={true}
                  showRank={true}
                  rank={index + 1}
                  type="trending"
                />
              </View>
            ))}
          </View>

          {/* Right column */}
          <View style={styles.trendingColumn}>
            {rightColumn.map((item, index) => (
              <View key={item.dramaId} style={styles.trendingItem}>
                <DramaCover
                  drama={item}
                  onPress={onItemPress}
                  width={cardWidth}
                  height={cardHeight}
                  showPlayCount={true}
                  showNewBadge={true}
                  showRank={true}
                  rank={index + 4}
                  type="trending"
                />
              </View>
            ))}
          </View>
        </View>
      </View>
    );
  }

  // New Release layout: horizontal scroll
  if (type === "new") {
    return (
      <View style={styles.container}>
        <Text style={styles.title}>{getTitle()}</Text>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.newScrollContainer}
        >
          {data.map((item) => (
            <View key={item.dramaId} style={styles.newItem}>
              <DramaCover
                drama={item}
                onPress={onItemPress}
                width={100}
                height={181}
                showPlayCount={true}
                showNewBadge={true}
                showRank={false}
                type="new"
              />
            </View>
          ))}
        </ScrollView>
      </View>
    );
  }

  // Recommend layout: two-column grid
  if (type === "recommend") {
    const cardWidth = (screenWidth - 48) / 2;
    const cardHeight = cardWidth * (287 / 167.49); // Based on design aspect ratio

    return (
      <View style={styles.container}>
        <Text style={styles.title}>{getTitle()}</Text>
        <View style={styles.recommendContainer}>
          {data.map((item) => (
            <View key={item.dramaId} style={styles.recommendItem}>
              <DramaCover
                drama={item}
                onPress={onItemPress}
                width={cardWidth}
                height={cardHeight}
                showPlayCount={true}
                showNewBadge={false}
                showRank={false}
                type="recommend"
              />
            </View>
          ))}
        </View>
      </View>
    );
  }

  return null;
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 48,
  },
  title: {
    fontSize: 18,
    fontWeight: "700",
    color: "#FFFFFF",
    marginBottom: 12,
    paddingHorizontal: 16,
    letterSpacing: 0.2,
  },
  // Trending layout styles
  trendingContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingHorizontal: 16,
  },
  trendingColumn: {
    flex: 1,
    gap: 24,
  },
  trendingItem: {
    marginBottom: 0,
  },
  // New Release layout styles
  newScrollContainer: {
    paddingHorizontal: 16,
    gap: 16,
  },
  newItem: {
    width: 100,
  },
  // Recommend layout styles
  recommendContainer: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    gap: 16,
  },
  recommendItem: {
    marginBottom: 16,
  },
});

export default DramaList;
