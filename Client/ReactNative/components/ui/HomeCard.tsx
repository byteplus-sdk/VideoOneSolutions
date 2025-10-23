// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React from "react";
import { View, Text, StyleSheet, TouchableOpacity } from "react-native";
import { Image } from "expo-image";
import { useRouter } from "expo-router";
import { getImageSource, getImageAsset } from "@/utils/imageUtils";

type HomeCardProps = {
  imgPath: any;
  title: string;
  subTitle: string;
  linkRoute: string | null;
};

const HomeCard: React.FC<HomeCardProps> = ({
  imgPath,
  title,
  subTitle,
  linkRoute,
}) => {
  const router = useRouter();

  const handlePress = () => {
    if (linkRoute) {
      (router as any).push(linkRoute);
    } else {
      alert("Coming Soon");
    }
  };

  const imageSource = getImageSource(imgPath);

  return (
    <TouchableOpacity
      onPress={handlePress}
      style={styles.container}
      activeOpacity={0.8}
    >
      <Image source={imageSource} style={styles.image} />
      <View style={styles.content}>
        <View style={styles.textContainer}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subTitle}>{subTitle}</Text>
        </View>
        <View style={styles.button}>
          <Image
            source={getImageAsset("left_arrow")}
            style={styles.arrowIcon}
          />
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
    borderRadius: 12,
    overflow: "hidden",
    backgroundColor: "#fff",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 16,
    elevation: 2,
    borderWidth: 4,
    borderColor: "#9A912F",
  },
  image: {
    width: "100%",
    height: 176,
  },
  content: {
    height: 74,
    paddingHorizontal: 16,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "#4A4C20",
  },
  textContainer: {
    flex: 1,
    gap: 2,
  },
  title: {
    fontSize: 18,
    fontWeight: "700",
    color: "#FFFFFF",
    lineHeight: 24,
  },
  subTitle: {
    fontSize: 12,
    fontWeight: "400",
    color: "#FFFFFF",
    opacity: 0.7,
    lineHeight: 16,
  },
  button: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "rgba(255, 255, 255, 0.2)",
    justifyContent: "center",
    alignItems: "center",
    padding: 6.8,
  },
  arrowIcon: {
    width: 13,
    height: 13,
    tintColor: "#FFFFFF",
  },
});

export default HomeCard;
