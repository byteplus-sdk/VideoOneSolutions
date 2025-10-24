// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useRef, useCallback, useEffect } from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { Image } from "expo-image";
import LottieView from "lottie-react-native";
import { getImageAsset } from "../../utils/imageUtils";

interface LikeButtonProps {
  likeCount: number;
  isLiked?: boolean;
  onLikeChange?: (isLiked: boolean, newCount: number) => void;
}

const LikeButton: React.FC<LikeButtonProps> = ({
  likeCount,
  isLiked: externalIsLiked,
  onLikeChange,
}) => {
  const [isLiked, setIsLiked] = useState(false);
  const [hideStaticIcon, setHideStaticIcon] = useState(false);
  const [showLikeAnimation, setShowLikeAnimation] = useState(false);
  const [showUnlikeAnimation, setShowUnlikeAnimation] = useState(false);

  const likeAnimationRef = useRef<LottieView>(null);
  const unlikeAnimationRef = useRef<LottieView>(null);

  useEffect(() => {
    if (externalIsLiked !== undefined) {
      setIsLiked(externalIsLiked);
    }
  }, [externalIsLiked]);

  const handleLikePress = useCallback(() => {
    const newLikedState = !isLiked;
    const newCount = newLikedState ? likeCount + 1 : likeCount - 1;
    setHideStaticIcon(true);
    if (isLiked) {
      setShowUnlikeAnimation(true);
      setTimeout(() => {
        if (unlikeAnimationRef.current) {
          unlikeAnimationRef.current.play();
        }
      }, 50);
    } else {
      setShowLikeAnimation(true);
      setTimeout(() => {
        if (likeAnimationRef.current) {
          likeAnimationRef.current.play();
        }
      }, 50);
    }
    setIsLiked(newLikedState);
    onLikeChange?.(newLikedState, newCount);
  }, [isLiked, likeCount, onLikeChange]);

  return (
    <TouchableOpacity
      style={styles.interactionButton}
      onPress={handleLikePress}
      activeOpacity={0.8}
    >
      <View style={styles.interactionButtonContainer}>
        {/* Like animation - use opacity to control show/hide */}
        <View
          style={[
            styles.animationContainer,
            { opacity: showLikeAnimation ? 1 : 0 },
          ]}
        >
          <LottieView
            ref={likeAnimationRef}
            source={getImageAsset("lottie/like")}
            style={styles.likeAnimation}
            autoPlay={false}
            loop={false}
            onAnimationFinish={() => {
              setHideStaticIcon(false);
              setShowLikeAnimation(false);
            }}
          />
        </View>

        <View
          style={[
            styles.animationContainer,
            { opacity: showUnlikeAnimation ? 1 : 0 },
          ]}
        >
          <LottieView
            ref={unlikeAnimationRef}
            source={getImageAsset("lottie/unlike")}
            style={styles.likeAnimation}
            autoPlay={false}
            loop={false}
            onAnimationFinish={() => {
              setHideStaticIcon(false);
              setShowUnlikeAnimation(false);
            }}
          />
        </View>

        <Image
          source={
            isLiked
              ? getImageAsset("common/like")
              : getImageAsset("common/unlike")
          }
          style={[styles.heartIcon, { opacity: hideStaticIcon ? 0 : 1 }]}
        />
      </View>
      <Text style={styles.interactionCount}>{likeCount}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  interactionButton: {
    alignItems: "center",
    gap: 2,
  },
  interactionButtonContainer: {
    width: 40,
    height: 40,
    justifyContent: "center",
    alignItems: "center",
  },
  animationContainer: {
    position: "absolute",
    width: 40,
    height: 40,
    justifyContent: "center",
    alignItems: "center",
  },
  heartIcon: {
    width: 40,
    height: 40,
  },
  interactionCount: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "400",
    textShadowColor: "rgba(0, 0, 0, 0.2)",
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 1,
  },
  likeAnimation: {
    width: 50,
    height: 50,
  },
});

export default LikeButton;
