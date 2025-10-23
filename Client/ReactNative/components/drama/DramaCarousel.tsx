// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useRef } from "react";
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
} from "react-native";
import { Image } from "expo-image";
import Carousel, { ICarouselInstance } from "react-native-reanimated-carousel";
import Animated, {
  interpolate,
  useAnimatedStyle,
  SharedValue,
} from "react-native-reanimated";
import { BlurView as _BlurView } from "expo-blur";
import { DramaChannelMeta } from "../../types/drama";
import { getImageAsset } from "../../utils/imageUtils";

const BlurView = Animated.createAnimatedComponent(_BlurView);

// Removed custom parallaxLayout function as we're using built-in mode="parallax"
interface DramaCarouselProps {
  data: DramaChannelMeta[];
  onItemPress: (drama: DramaChannelMeta) => void;
}

const { width: screenWidth } = Dimensions.get("window");
const PAGE_WIDTH = Math.round(screenWidth * 0.7);
const PAGE_HEIGHT = Math.round(PAGE_WIDTH * (4 / 3));

const DramaCarousel: React.FC<DramaCarouselProps> = ({ data, onItemPress }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const carouselRef = useRef<ICarouselInstance>(null);

  const handleItemPress = (drama: DramaChannelMeta) => {
    onItemPress(drama);
  };

  const renderItem = ({
    item,
    index,
    animationValue,
  }: {
    item: DramaChannelMeta;
    index: number;
    animationValue: SharedValue<number>;
  }) => {
    return (
      <CustomItem
        key={index}
        index={index}
        item={item}
        animationValue={animationValue}
        onPress={() => handleItemPress(item)}
      />
    );
  };

  if (data.length === 0) {
    return null;
  }

  return (
    <View style={styles.container}>
      <Carousel
        ref={carouselRef}
        loop={true}
        autoPlay={data.length > 1}
        autoPlayInterval={8000}
        style={{
          width: screenWidth,
          justifyContent: "center",
          alignItems: "center",
        }}
        width={PAGE_WIDTH}
        data={data}
        renderItem={renderItem}
        pagingEnabled={true}
        snapEnabled={true}
        mode="parallax"
        modeConfig={{
          parallaxScrollingScale: 1,
          parallaxAdjacentItemScale: 0.8,
          parallaxScrollingOffset: 10,
        }}
        scrollAnimationDuration={1200}
        onSnapToItem={(index) => setCurrentIndex(index)}
      />

      {/* Indicators */}
      <View style={styles.indicatorContainer}>
        {data.map((_, index) => (
          <View
            key={index}
            style={[
              styles.indicator,
              index === currentIndex && styles.activeIndicator,
            ]}
          />
        ))}
      </View>
    </View>
  );
};

interface CustomItemProps {
  index: number;
  item: DramaChannelMeta;
  animationValue: SharedValue<number>;
  onPress: () => void;
}

const CustomItem: React.FC<CustomItemProps> = ({
  index,
  item,
  animationValue,
  onPress,
}) => {
  const maskStyle = useAnimatedStyle(() => {
    const opacity = interpolate(
      animationValue.value,
      [-1, -0.5, 0, 0.5, 1],
      [1, 0.8, 0, 0.8, 1]
    );

    return {
      opacity,
    };
  }, [animationValue]);

  return (
    <View
      style={{
        flex: 1,
        overflow: "hidden",
        justifyContent: "center",
        alignItems: "center",
        borderRadius: 12,
      }}
    >
      <TouchableOpacity
        style={styles.itemContainer}
        onPress={onPress}
        activeOpacity={0.8}
      >
        <View style={styles.imageContainer}>
          <Image source={{ uri: item.dramaCoverUrl }} style={styles.image} />

          {/* Play button */}
          <View style={styles.playButton}>
            <Image
              source={getImageAsset("drama/playButton")}
              style={styles.playIcon}
            />
            <Text style={styles.playText}>Play Now</Text>
          </View>

          {/* Blur mask overlay - moved inside imageContainer */}
          <BlurView
            intensity={80}
            pointerEvents="none"
            style={[StyleSheet.absoluteFill, maskStyle]}
          />
        </View>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    height: PAGE_HEIGHT + 80,
    alignItems: "center",
  },
  itemWrapper: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  itemContainer: {
    width: PAGE_WIDTH,
    height: PAGE_HEIGHT,
    marginHorizontal: 0,
  },
  imageContainer: {
    width: "100%",
    height: "100%",
    overflow: "hidden",
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "rgba(255, 255, 255, 0.3)",
    shadowColor: "#fff",
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 8,
    elevation: 8,
  },
  image: {
    width: "100%",
    height: "100%",
  },
  titleOverlay: {
    position: "absolute",
    bottom: 20,
    left: 16,
    right: 16,
  },
  playButton: {
    position: "absolute",
    bottom: 20,
    left: "50%",
    transform: [{ translateX: -50 }],
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(255, 23, 100, 0.9)",
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 4,
  },
  playIcon: {
    width: 16,
    height: 16,
    marginRight: 6,
    tintColor: "#fff",
  },
  playText: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "600",
  },
  indicatorContainer: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginTop: 24,
    paddingHorizontal: 20,
    gap: 8,
  },
  indicator: {
    width: 8,
    height: 4,
    borderRadius: 2,
    backgroundColor: "rgba(255, 255, 255, 0.2)",
  },
  activeIndicator: {
    width: 20,
    height: 4,
    borderRadius: 2,
    backgroundColor: "rgba(255, 255, 255, 0.8)",
  },
});

export default DramaCarousel;
