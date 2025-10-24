// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useRef, useCallback } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Animated,
  Easing,
} from "react-native";
import { Image } from "expo-image";
import { getImageAsset } from "../../utils/imageUtils";
import * as ScreenOrientation from "expo-screen-orientation";
import LikeButton from "../ui/LikeButton";
import LandscapeSpeedSelector from "../ui/LandscapeSpeedSelector";
import LandscapeQualitySelector from "../ui/LandscapeQualitySelector";
import LandscapeEpisodeSelector from "../ui/LandscapeEpisodeSelector";
import UserAvatar from "../shared/UserAvatar";
import { DramaEpisode, IPlayInfoListItem } from "../../types/drama";

interface PlaybackControlsProps {
  // Basic state
  currentOrientation: ScreenOrientation.Orientation;
  isPlaying: boolean;
  showPlayButton: boolean;
  showLoading: boolean;

  // Playback control
  onPlayPause: () => void;
  onVideoPress: () => void;
  onFullscreenPress: () => void;

  // Like and comment
  currentLikeCount: number;
  isLiked: boolean;
  currentCommentCount: number;
  isCommented: boolean;
  onLikePress: () => void;
  onCommentPress: () => void;

  // Speed control
  playbackSpeed: number;
  onSpeedChange?: (speed: number) => void;

  // Quality control
  playInfoList: IPlayInfoListItem[];
  currentQuality: string;
  onQualityChange: (quality: string, playInfo: IPlayInfoListItem) => void;

  // Episode selection control
  episodes: DramaEpisode[];
  currentEpisodeIndex: number;
  dramaTitle: string;
  dramaCoverUrl: string;
  dramaId: string;
  onEpisodeSelect?: (index: number) => void;

  // Fullscreen button position
  fullscreenButtonPosition: { top?: number; bottom?: number };

  // Drama video orientation
  dramaVideoOrientation?: number;

  // Feed tab indicator
  isFeedTab?: boolean;
}

const PlaybackControls: React.FC<PlaybackControlsProps> = ({
  currentOrientation,
  isPlaying,
  showPlayButton,
  showLoading,
  onPlayPause,
  onVideoPress,
  onFullscreenPress,
  currentLikeCount,
  isLiked,
  currentCommentCount,
  isCommented,
  onLikePress,
  onCommentPress,
  playbackSpeed,
  onSpeedChange,
  playInfoList,
  currentQuality,
  onQualityChange,
  episodes,
  currentEpisodeIndex,
  dramaTitle,
  dramaCoverUrl,
  dramaId,
  onEpisodeSelect,
  fullscreenButtonPosition,
  dramaVideoOrientation = 0,
  isFeedTab = false,
}) => {
  const isPortrait =
    currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP;

  // Animation values for play button
  const playButtonOpacity = useRef(new Animated.Value(0)).current;
  const playButtonScale = useRef(new Animated.Value(0.8)).current;

  // Animation function
  const animatePlayButton = useCallback(
    (shouldShow: boolean) => {
      if (shouldShow) {
        // Reset animation values
        playButtonOpacity.setValue(0);
        playButtonScale.setValue(0.8);

        // Start animation sequence
        Animated.parallel([
          // Fade in animation
          Animated.timing(playButtonOpacity, {
            toValue: 1,
            duration: 300,
            useNativeDriver: true,
          }),
          // Scale animation: first scale up, then scale down to normal size
          Animated.sequence([
            // Scale up to 1.2
            Animated.timing(playButtonScale, {
              toValue: 1.2,
              duration: 200,
              easing: Easing.out(Easing.cubic),
              useNativeDriver: true,
            }),
            // Scale down to normal size
            Animated.timing(playButtonScale, {
              toValue: 1,
              duration: 200,
              easing: Easing.inOut(Easing.cubic),
              useNativeDriver: true,
            }),
          ]),
        ]).start();
      } else {
        // Hide animation
        Animated.parallel([
          Animated.timing(playButtonOpacity, {
            toValue: 0,
            duration: 200,
            useNativeDriver: true,
          }),
          Animated.timing(playButtonScale, {
            toValue: 0.8,
            duration: 200,
            easing: Easing.in(Easing.cubic),
            useNativeDriver: true,
          }),
        ]).start();
      }
    },
    [playButtonOpacity, playButtonScale]
  );

  // Animate play button when it appears
  useEffect(() => {
    animatePlayButton(showPlayButton);
  }, [showPlayButton, animatePlayButton]);

  return (
    <>
      {/* Play button with animation */}
      <Animated.View
        style={[
          styles.playButtonContainer,
          {
            opacity: playButtonOpacity,
            transform: [{ scale: playButtonScale }],
          },
        ]}
        pointerEvents="box-none"
      >
        {showPlayButton && (
          <TouchableOpacity style={styles.playButton} onPress={onPlayPause}>
            <Image
              source={getImageAsset("player/btn_play")}
              style={styles.playButtonIcon}
            />
          </TouchableOpacity>
        )}
      </Animated.View>

      {/* Loading indicator */}
      {showLoading && (
        <View style={styles.loadingContainer} pointerEvents="box-none">
          <ActivityIndicator size="large" color="#fff" />
        </View>
      )}

      {isPortrait && dramaVideoOrientation === 1 && !isFeedTab && (
        <View
          style={[styles.fullscreenButtonContainer, fullscreenButtonPosition]}
        >
          <TouchableOpacity
            style={styles.fullscreenButton}
            onPress={onFullscreenPress}
            activeOpacity={0.8}
          >
            <View style={styles.fullscreenIcon}>
              <Image
                source={getImageAsset("player/fullscreen")}
                style={styles.fullscreenIconImage}
              />
            </View>
            <Text style={styles.fullscreenButtonText}>Full screen</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Landscape control buttons - Only show in landscape mode */}
      {!isPortrait && (
        <View style={styles.landscapeControlsContainer}>
          {/* Left: Like and comment buttons */}
          <View style={styles.landscapeLeftControls}>
            {/* Like button */}
            <View style={styles.landscapeControlButton}>
              <TouchableOpacity
                style={styles.landscapeControlButtonContainer}
                onPress={onLikePress}
              >
                <Image
                  source={
                    isLiked
                      ? getImageAsset("player/v_like")
                      : getImageAsset("player/v_unlike")
                  }
                  style={styles.landscapeControlIcon}
                />
              </TouchableOpacity>
              <Text style={styles.landscapeControlNumber}>
                {currentLikeCount}
              </Text>
            </View>

            {/* Comment button */}
            <View style={styles.landscapeControlButton}>
              <TouchableOpacity
                style={styles.landscapeControlButtonContainer}
                onPress={onCommentPress}
              >
                <Image
                  source={getImageAsset("player/v_comment")}
                  style={styles.landscapeControlIcon}
                />
              </TouchableOpacity>
              <Text style={styles.landscapeControlNumber}>
                {currentCommentCount}
              </Text>
            </View>
          </View>

          {/* Right: Speed, quality, episode selector buttons */}
          <View style={styles.landscapeRightControls}>
            {/* Speed button */}
            <LandscapeSpeedSelector
              currentSpeed={playbackSpeed}
              onSpeedChange={onSpeedChange || (() => {})}
            />

            {/* Quality button */}
            <LandscapeQualitySelector
              playInfoList={playInfoList}
              currentQuality={currentQuality}
              onQualityChange={onQualityChange}
            />

            {/* Episode selector button */}
            <LandscapeEpisodeSelector
              episodes={episodes}
              currentEpisodeIndex={currentEpisodeIndex}
              onEpisodeSelect={onEpisodeSelect || (() => {})}
              dramaTitle={dramaTitle}
              dramaCoverUrl={dramaCoverUrl}
              dramaId={dramaId}
            />
          </View>
        </View>
      )}

      {/* Right interaction area - Only show in portrait mode */}
      {isPortrait && (
        <View style={styles.rightInteractionArea}>
          {/* Avatar - Only show in feed tab */}
          {isFeedTab && (
            <View style={styles.avatarContainer}>
              <UserAvatar size={40} />
            </View>
          )}

          {/* Like button */}
          <LikeButton
            likeCount={currentLikeCount}
            isLiked={isLiked}
            onLikeChange={(isLiked, newCount) => {
              onLikePress();
            }}
          />

          {/* Comment button */}
          <TouchableOpacity
            style={styles.interactionButton}
            onPress={onCommentPress}
            activeOpacity={0.8}
          >
            <View style={styles.interactionButtonContainer}>
              <Image
                source={getImageAsset("common/comment")}
                style={styles.commentIcon}
              />
            </View>
            <Text style={styles.interactionCount}>{currentCommentCount}</Text>
          </TouchableOpacity>
        </View>
      )}
    </>
  );
};

const styles = StyleSheet.create({
  pauseOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: "transparent",
    zIndex: 10,
  },
  playButtonContainer: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "center",
    alignItems: "center",
    zIndex: 10,
  },
  playButton: {
    width: 80,
    height: 80,
    justifyContent: "center",
    alignItems: "center",
  },
  playButtonIcon: {
    width: 80,
    height: 80,
  },
  loadingContainer: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "center",
    alignItems: "center",
    zIndex: 15,
  },
  fullscreenButtonContainer: {
    position: "absolute",
    left: 0,
    right: 0,
    alignItems: "center",
    zIndex: 100,
  },
  fullscreenButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(41, 41, 41, 0.34)",
    borderWidth: 0.5,
    borderColor: "rgba(255, 255, 255, 0.2)",
    borderRadius: 4,
    paddingHorizontal: 8,
    paddingVertical: 6,
    gap: 8,
  },
  fullscreenIcon: {
    width: 20,
    height: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  fullscreenIconImage: {
    width: 20,
    height: 20,
    tintColor: "#FFFFFF",
  },
  fullscreenButtonText: {
    color: "#FFFFFF",
    fontSize: 12,
    fontWeight: "400",
    lineHeight: 16,
  },
  landscapeControlsContainer: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 10,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    zIndex: 30,
  },
  landscapeLeftControls: {
    flexDirection: "row",
    alignItems: "center",
    gap: 24,
  },
  landscapeRightControls: {
    flexDirection: "row",
    alignItems: "center",
    gap: 32,
    paddingHorizontal: 40,
  },
  landscapeControlButton: {
    width: 40,
    height: 40,
    alignItems: "center",
    justifyContent: "center",
    position: "relative",
  },
  landscapeControlButtonContainer: {
    width: 28,
    height: 28,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "transparent",
  },
  landscapeControlIcon: {
    width: 28,
    height: 28,
    tintColor: "#FFFFFF",
  },
  landscapeControlNumber: {
    color: "#FFFFFF",
    fontSize: 10,
    fontWeight: "700",
    lineHeight: 12,
    textAlign: "left",
    fontFamily: "SF Compact Display",
    position: "absolute",
    bottom: 8,
    right: 0,
    minWidth: 18,
  },
  rightInteractionArea: {
    position: "absolute",
    right: 16,
    bottom: 60,
    flexDirection: "column",
    alignItems: "center",
    gap: 16,
    zIndex: 30,
  },
  avatarContainer: {
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 8,
  },
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
  commentIcon: {
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
});

export default PlaybackControls;
