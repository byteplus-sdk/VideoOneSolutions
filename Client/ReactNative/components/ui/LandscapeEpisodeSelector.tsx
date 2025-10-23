// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useCallback } from "react";
import { Text, TouchableOpacity, StyleSheet } from "react-native";
import { Image } from "expo-image";
import { DramaEpisode } from "../../types/drama";
import EpisodeSelectorModal from "../modals/EpisodeSelectorModal";
import { getImageAsset } from "../../utils/imageUtils";

interface LandscapeEpisodeSelectorProps {
  episodes: DramaEpisode[];
  currentEpisodeIndex: number;
  onEpisodeSelect: (index: number) => void;
  dramaTitle: string;
  dramaCoverUrl: string;
  dramaId: string;
  onEpisodeUnlocked?: (
    episodeIndex: number,
    unlockData?: { video_model: string; subtitle_auth_token: string }
  ) => void;
  onUnlockAllPress?: () => void;
}

const LandscapeEpisodeSelector: React.FC<LandscapeEpisodeSelectorProps> = ({
  episodes,
  currentEpisodeIndex,
  onEpisodeSelect,
  dramaTitle,
  dramaCoverUrl,
  dramaId,
  onEpisodeUnlocked,
  onUnlockAllPress,
}) => {
  const [isVisible, setIsVisible] = useState(false);

  const showModal = useCallback(() => {
    setIsVisible(true);
  }, []);

  const hideModal = useCallback(() => {
    setIsVisible(false);
  }, []);

  const handleEpisodeSelect = (index: number) => {
    onEpisodeSelect(index);
    hideModal();
  };

  // get current episode text
  const getCurrentEpisodeText = () => {
    const currentEpisode = episodes[currentEpisodeIndex];
    return currentEpisode ? `${currentEpisode.order}` : "1";
  };

  return (
    <>
      {/* Landscape episode selector button */}
      <TouchableOpacity
        style={styles.landscapeEpisodeButton}
        onPress={showModal}
      >
        <Image
          source={getImageAsset("player/series")}
          style={styles.landscapeEpisodeIcon}
        />
        <Text style={styles.landscapeEpisodeText}>
          {getCurrentEpisodeText()}
        </Text>
      </TouchableOpacity>

      {/* Episode selector modal */}
      <EpisodeSelectorModal
        episodes={episodes}
        currentEpisodeIndex={currentEpisodeIndex}
        onEpisodeSelect={handleEpisodeSelect}
        visible={isVisible}
        onClose={hideModal}
        dramaTitle={dramaTitle}
        dramaCoverUrl={dramaCoverUrl}
        dramaId={dramaId}
        onEpisodeUnlocked={onEpisodeUnlocked}
        onUnlockAllPress={onUnlockAllPress}
      />
    </>
  );
};

const styles = StyleSheet.create({
  landscapeEpisodeButton: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "transparent",
    gap: 4,
  },
  landscapeEpisodeIcon: {
    width: 20,
    height: 20,
    tintColor: "#FFFFFF",
  },
  landscapeEpisodeText: {
    color: "#FFFFFF",
    fontSize: 15,
    fontWeight: "600",
    lineHeight: 24,
    textAlign: "center",
    fontFamily: "PingFang SC",
  },
});

export default LandscapeEpisodeSelector;
