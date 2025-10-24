// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect, useMemo } from "react";
import { View, StyleSheet, Dimensions } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import * as ScreenOrientation from "expo-screen-orientation";
import { VideoPlayer } from "./VideoPlayer";
import EpisodeSelector from "../ui/EpisodeSelector";
import PlaybackSpeedSelector from "../ui/PlaybackSpeedSelector";
import { DramaEpisode } from "../../types/drama";

const getScreenDimensions = () => {
  const { width: screenWidth, height: screenHeight } = Dimensions.get("window");
  return { width: screenWidth, height: screenHeight };
};

interface EpisodePlayerProps {
  episode: DramaEpisode;
  dramaTitle: string;
  dramaCoverUrl: string;
  episodes: DramaEpisode[];
  currentEpisodeIndex: number;
  playerIndex: number;
  onPlayPause?: (isPlaying: boolean) => void;
  onProgress?: (progress: number) => void;
  onError?: (error: string) => void;
  onEpisodeSelectorPress?: () => void;
  onRecommendationPress?: () => void;
  onDidFinish?: () => void; // Callback when video finishes playing
  dramaId?: string;
  playbackSpeed: number;
  onSpeedChange: (speed: number) => void;
  dramaVideoOrientation?: number;
  startTime?: number;
  onEpisodeSelect?: (index: number) => void;
  shouldTriggerScrollPreRender?: boolean; // Flag to trigger scroll pre-render
  onFullscreen?: () => void;
}

const EpisodePlayer: React.FC<EpisodePlayerProps> = ({
  episode,
  dramaTitle,
  dramaCoverUrl,
  episodes,
  currentEpisodeIndex,
  playerIndex,
  onPlayPause,
  onProgress,
  onError,
  onEpisodeSelectorPress,
  onRecommendationPress,
  onDidFinish,
  dramaId,
  playbackSpeed,
  onSpeedChange,
  dramaVideoOrientation = 0,
  startTime = 0,
  onEpisodeSelect,
  shouldTriggerScrollPreRender = false,
  onFullscreen,
}) => {
  const [screenDimensions, setScreenDimensions] = useState(
    getScreenDimensions()
  );
  const [currentOrientation, setCurrentOrientation] = useState(
    ScreenOrientation.Orientation.PORTRAIT_UP
  );

  // Listen to screen orientation changes
  useEffect(() => {
    const initializeOrientation = async () => {
      try {
        const orientation = await ScreenOrientation.getOrientationAsync();
        setCurrentOrientation(orientation);
        setScreenDimensions(getScreenDimensions());
      } catch (error) {
        console.error("Failed to get initial orientation:", error);
      }
    };

    initializeOrientation();

    const subscription = ScreenOrientation.addOrientationChangeListener(
      (event) => {
        const newOrientation = event.orientationInfo.orientation;
        setCurrentOrientation(newOrientation);
        setScreenDimensions(getScreenDimensions());
      }
    );

    return () => {
      subscription.remove();
    };
  }, []);

  // Create dynamic styles
  const styles = useMemo(
    () =>
      StyleSheet.create({
        container: {
          flex: 1,
          backgroundColor: "#000",
        },
        videoContainer: {
          width: "100%",
        },
        bottomBar: {
          position: "absolute",
          bottom: 0,
          left: 0,
          right: 0,
          backgroundColor: "rgba(0, 0, 0, 0.8)",
          paddingTop: 12,
          paddingHorizontal: 16,
          paddingBottom: 16,
          zIndex: 20,
          height: 80,
        },
        bottomControlsContainer: {
          flexDirection: "row",
          justifyContent: "space-between",
          alignItems: "center",
        },
      }),
    []
  );

  return (
    <View style={styles.container}>
      <View
        style={[
          styles.videoContainer,
          {
            height:
              currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP
                ? screenDimensions.height - styles.bottomBar.height
                : screenDimensions.height,
          },
        ]}
      >
        <VideoPlayer
          episode={episode}
          dramaTitle={dramaTitle}
          dramaCoverUrl={dramaCoverUrl}
          currentIndex={currentEpisodeIndex}
          episodes={episodes}
          startTime={startTime}
          currentEpisodeIndex={currentEpisodeIndex}
          playerIndex={playerIndex}
          onPlayPause={onPlayPause}
          onProgress={onProgress}
          onError={onError}
          onFullscreen={onFullscreen}
          onDidFinish={onDidFinish}
          dramaId={dramaId}
          dramaVideoOrientation={dramaVideoOrientation}
          playbackSpeed={playbackSpeed}
          onSpeedChange={onSpeedChange}
          onEpisodeSelect={onEpisodeSelect}
          shouldTriggerScrollPreRender={shouldTriggerScrollPreRender}
        />
      </View>

      {currentOrientation === ScreenOrientation.Orientation.PORTRAIT_UP && (
        <SafeAreaView style={styles.bottomBar} edges={["bottom"]}>
          <View style={styles.bottomControlsContainer}>
            <EpisodeSelector
              episodes={episodes}
              onPress={onEpisodeSelectorPress}
            />

            <PlaybackSpeedSelector
              currentSpeed={playbackSpeed}
              onSpeedChange={onSpeedChange}
            />
          </View>
        </SafeAreaView>
      )}
    </View>
  );
};

export default EpisodePlayer;
