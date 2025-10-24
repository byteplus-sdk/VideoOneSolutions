// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, {
  useState,
  useRef,
  useEffect,
  useCallback,
  useMemo,
} from "react";
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  Dimensions,
  TouchableOpacity,
  FlatList,
} from "react-native";
import { Image } from "expo-image";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useLocalSearchParams, router } from "expo-router";
import * as ScreenOrientation from "expo-screen-orientation";
import { DramaService } from "@/services/dramaService";
import { DramaEpisode } from "@/types/drama";
import {
  EpisodePlayer,
  EpisodeSelectorModal,
  VipUnlockModal,
  UnlockMultipleModal,
} from "../components";
import { setStrategyList, addStrategyList } from "@/utils/dramaUtils";
import {
  setPreRenderCallback,
  TTVideoEngine,
  VideoSource,
} from "../utils/playerConfig";

// Get screen dimensions, swap width and height in landscape mode
const getScreenDimensions = () => {
  const { width: screenWidth, height: screenHeight } = Dimensions.get("window");
  return { width: screenWidth, height: screenHeight };
};

export default function DramaPlayer() {
  const params = useLocalSearchParams();
  const insets = useSafeAreaInsets();
  const [loading, setLoading] = useState(true);
  const [episodes, setEpisodes] = useState<DramaEpisode[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [playbackSpeed, setPlaybackSpeed] = useState(1);
  const [scrollStartY, setScrollStartY] = useState(0);
  const [shouldTriggerScrollPreRender, setShouldTriggerScrollPreRender] =
    useState(false);
  // Modal state management
  const [showEpisodeSelector, setShowEpisodeSelector] = useState(false);
  const [showVipModal, setShowVipModal] = useState(false);
  const [showUnlockMultiple, setShowUnlockMultiple] = useState(false);
  // Screen orientation state
  const [isLandscape, setIsLandscape] = useState(false);
  const [isTransitioningOrientation, setIsTransitioningOrientation] =
    useState(false);
  const suppressViewabilityRef = useRef(false);
  // Screen dimensions state
  const [screenDimensions, setScreenDimensions] = useState(
    getScreenDimensions()
  );

  const flashListRef = useRef<any>(null);

  // Parse route parameters
  const dramaId = params.dramaId as string;
  const dramaTitle =
    episodes[currentIndex]?.caption || (params.dramaTitle as string);
  const dramaCoverUrl = params.dramaCoverUrl as string;
  const dramaVideoOrientation =
    parseInt(params.dramaVideoOrientation as string) || 0;
  const episodeOrder = params.episodeOrder
    ? parseInt(params.episodeOrder as string)
    : 1;
  const startTime = parseInt(params.startTime as string) || 0;

  useEffect(() => {
    if (episodeOrder !== undefined) {
      setCurrentIndex(episodeOrder - 1);
    }
  }, [episodeOrder]);

  // Get episode data
  const fetchEpisodes = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const episodesData = await DramaService.getDramaList({
        drama_id: dramaId,
      });

      setEpisodes(episodesData);
      setStrategyList(episodesData);

      // If episode number is specified, jump to corresponding episode
      if (episodeOrder !== undefined) {
        const targetIndex = episodesData.findIndex(
          (ep) => ep.order === episodeOrder
        );
        if (targetIndex !== -1) {
          setCurrentIndex(targetIndex);
        }
      }

      setLoading(false);
    } catch (err) {
      console.error("Failed to fetch episodes:", err);
      setError(err instanceof Error ? err.message : "Failed to load episodes");
      setLoading(false);
    }
  }, [dramaId, episodeOrder]);

  // Return to previous route
  const handleBackPress = useCallback(async () => {
    if (isLandscape) {
      await ScreenOrientation.lockAsync(
        ScreenOrientation.OrientationLock.PORTRAIT_UP
      );
    } else {
      router.back();
    }
  }, [isLandscape]);

  // Handle episode unlock
  const handleEpisodeUnlocked = useCallback(
    (
      episodeIndex: number,
      unlockData?: { video_model: string; subtitle_auth_token: string }
    ) => {
      setEpisodes((prevEpisodes) =>
        prevEpisodes.map((episode, index) => {
          if (index === episodeIndex) {
            return {
              ...episode,
              vip: false, // Remove VIP status after unlock
              video_model: unlockData?.video_model || episode.video_model, // Update video_model
              subtitle_auth_token:
                unlockData?.subtitle_auth_token || episode.subtitle_auth_token, // Update subtitle_auth_token
            };
          }
          return episode;
        })
      );
    },
    []
  );

  // Initialize data
  useEffect(() => {
    fetchEpisodes();
    setPreRenderCallback({
      onPlayerCreated(player: TTVideoEngine, source: VideoSource) {
        console.log("EngineStrategy:onPlayerCreated", source.vid());
      },
    });
  }, [fetchEpisodes]);

  // Listen to screen orientation changes
  useEffect(() => {
    const initializeOrientation = async () => {
      try {
        const orientation = await ScreenOrientation.getOrientationAsync();
        const isCurrentlyLandscape =
          orientation === ScreenOrientation.Orientation.LANDSCAPE_LEFT ||
          orientation === ScreenOrientation.Orientation.LANDSCAPE_RIGHT;
        setIsLandscape(isCurrentlyLandscape);
      } catch (error) {
        console.error("Failed to get initial orientation:", error);
      }
    };

    initializeOrientation();

    const subscription = ScreenOrientation.addOrientationChangeListener(
      (event) => {
        const newOrientation = event.orientationInfo.orientation;
        const isCurrentlyLandscape =
          newOrientation === ScreenOrientation.Orientation.LANDSCAPE_LEFT ||
          newOrientation === ScreenOrientation.Orientation.LANDSCAPE_RIGHT;
        setIsLandscape(isCurrentlyLandscape);
        // Freeze index during orientation transition to avoid viewability re-pick
        suppressViewabilityRef.current = true;
        setIsTransitioningOrientation(true);
        // Update screen dimensions, then re-align to current index after a short delay
        setScreenDimensions(getScreenDimensions());
        setTimeout(() => {
          if (flashListRef.current) {
            const targetOffset = screenDimensions.height * currentIndex;
            flashListRef.current.scrollToOffset({
              offset: targetOffset,
              animated: false,
            });
          }
          suppressViewabilityRef.current = false;
          setIsTransitioningOrientation(false);
        }, 400);
      }
    );

    return () => {
      subscription.remove();
    };
  }, [currentIndex, screenDimensions.height]);

  // Check if current episode is VIP, show unlock modal if so
  useEffect(() => {
    // If UnlockMultipleModal is showing, don't show VIP modal
    if (showUnlockMultiple) {
      setShowVipModal(false);
      return;
    }

    // Delay VIP status check to avoid immediately showing VIP modal after unlock
    const timer = setTimeout(() => {
      if (episodes.length > 0 && episodes[currentIndex]?.vip) {
        setShowVipModal(true);
      } else {
        setShowVipModal(false);
      }
    }, 500); // Delay 500ms

    return () => clearTimeout(timer);
  }, [episodes, currentIndex, showUnlockMultiple]);

  // Handle playback state change
  const handlePlayPause = useCallback((playing: boolean) => {
    // Playback state change handling, now managed internally by VideoPlayer
  }, []);

  // Handle episode switching
  const handleEpisodeChange = useCallback(
    (index: number, animated?: boolean) => {
      setCurrentIndex(index);
      if (flashListRef.current) {
        const isNear = Math.abs(index - currentIndex) <= 1;
        flashListRef.current.scrollToIndex({ index, animated: isNear });
      }
    },
    [currentIndex]
  );

  // Handle video finish - auto switch to next episode
  const handleVideoFinish = useCallback(() => {
    if (currentIndex < episodes.length - 1) {
      // Switch to next episode
      const nextIndex = currentIndex + 1;
      handleEpisodeChange(nextIndex, true);
    }
  }, [currentIndex, episodes.length, handleEpisodeChange]);

  // Handle episode selector modal
  const handleEpisodeSelectorPress = useCallback(() => {
    setShowEpisodeSelector(true);
  }, []);

  // Handle episode selection
  const handleEpisodeSelect = useCallback(
    (index: number) => {
      if (index !== currentIndex) {
        handleEpisodeChange(index);
      }
      setShowEpisodeSelector(false);
    },
    [currentIndex, handleEpisodeChange]
  );

  // Handle VIP unlock
  const handleVipUnlock = useCallback(
    (
      success: boolean,
      unlockData?: { video_model: string; subtitle_auth_token: string }
    ) => {
      if (success && unlockData) {
        handleEpisodeUnlocked(currentIndex, unlockData);
        const vid = episodes[currentIndex]?.vid;
        // add strategy list for prerender and preload
        addStrategyList([{ ...unlockData, vid, vip: false }]);
      }
      setShowVipModal(false);
    },
    [currentIndex, episodes, handleEpisodeUnlocked]
  );

  // Handle multiple episodes unlock success
  const handleUnlockMultipleSuccess = useCallback(
    (
      unlockDataList: {
        video_model: string;
        subtitle_auth_token: string;
        vid: string;
      }[]
    ) => {
      setShowUnlockMultiple(false);
      // Immediately close VIP modal to avoid re-display
      setShowVipModal(false);

      unlockDataList.forEach((unlockData) => {
        const episodeIndex = episodes.findIndex(
          (ep) => ep.vid === unlockData.vid
        );
        if (episodeIndex !== undefined && episodeIndex >= 0) {
          handleEpisodeUnlocked(episodeIndex, {
            video_model: unlockData.video_model,
            subtitle_auth_token: unlockData.subtitle_auth_token,
          });
        }
      });
      // add strategy list for prerender and preload
      addStrategyList(unlockDataList.map((item) => ({ ...item, vip: false })));
    },
    [episodes, handleEpisodeUnlocked]
  );

  // Create viewability config callback pairs
  const viewabilityConfigCallbackPairs = useMemo(
    () => [
      {
        viewabilityConfig: {
          itemVisiblePercentThreshold: 50,
          minimumViewTime: 300,
          waitForInteraction: false,
        },
        onViewableItemsChanged: ({ viewableItems }: any) => {
          if (suppressViewabilityRef.current) return;
          if (viewableItems.length > 0) {
            const newIndex = viewableItems[0].index;
            setCurrentIndex((prevIndex) => {
              if (newIndex !== prevIndex) {
                return newIndex;
              }
              return prevIndex;
            });
          }
        },
      },
    ],
    []
  );

  const handleFullscreenFreeze = useCallback(
    (isFullscreen?: boolean, index?: number) => {
      // Keep the list anchored on the current (or provided) index during fullscreen transitions
      const targetIndex = index ?? currentIndex;
      suppressViewabilityRef.current = true;
      // Short delay to wait for orientation lock to settle when exiting fullscreen
      const delay = isFullscreen ? 0 : 300;
      setTimeout(() => {
        if (flashListRef.current) {
          try {
            flashListRef.current.scrollToIndex({
              index: targetIndex,
              animated: false,
            });
          } catch {}
        }
        suppressViewabilityRef.current = false;
      }, delay);
    },
    [currentIndex]
  );

  // Handle scroll distance limit
  const handleScrollBeginDrag = useCallback((event: any) => {
    setScrollStartY(event.nativeEvent.contentOffset.y);
  }, []);

  const handleScrollEndDrag = useCallback(
    (event: any) => {
      const scrollEndY = event.nativeEvent.contentOffset.y;
      const scrollDistance = Math.abs(scrollEndY - scrollStartY);
      const isScrollingDown = scrollEndY > scrollStartY;

      // Trigger scroll pre-render when scrolling down
      if (isScrollingDown && scrollDistance > 50) {
        setShouldTriggerScrollPreRender(true);
        // Reset the flag after a short delay
        setTimeout(() => setShouldTriggerScrollPreRender(false), 100);
      }
    },
    [scrollStartY]
  );

  // Ensure at most one item moves per gesture and snap to start
  const handleMomentumScrollEnd = useCallback(
    (event: any) => {
      const offsetY = event.nativeEvent.contentOffset.y;
      const itemHeight = screenDimensions.height;
      const intendedIndex = Math.round(offsetY / itemHeight);
      const minIndex = Math.max(0, currentIndex - 1);
      const maxIndex = Math.min(episodes.length - 1, currentIndex + 1);
      const clampedIndex = Math.max(
        minIndex,
        Math.min(maxIndex, intendedIndex)
      );

      if (clampedIndex !== intendedIndex) {
        // Snap to the nearest allowed index (at most one away)
        if (flashListRef.current) {
          flashListRef.current.scrollToIndex({
            index: clampedIndex,
            animated: true,
          });
        }
      }
    },
    [currentIndex, episodes.length, screenDimensions.height]
  );

  // Create dynamic styles
  const styles = useMemo(
    () =>
      StyleSheet.create({
        container: {
          flex: 1,
          backgroundColor: "#000",
          position: "relative",
        },
        titleBar: {
          position: "absolute",
          left: 10,
          right: 20,
          zIndex: 1000,
          flexDirection: "row",
          alignItems: "center",
        },
        backButton: {
          padding: 8,
          marginRight: 12,
        },
        backIcon: {
          width: 20,
          height: 20,
          tintColor: "#fff",
        },
        titleText: {
          color: "#fff",
          fontSize: 18,
          fontWeight: "bold",
          flex: 1, // Take remaining space
        },
        loadingContainer: {
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: "#000",
        },
        loadingText: {
          marginTop: 12,
          color: "#fff",
          fontSize: 16,
        },
        errorText: {
          color: "#ff4444",
          fontSize: 16,
          textAlign: "center",
          marginBottom: 20,
        },
        retryButton: {
          backgroundColor: "#1664FF",
          paddingHorizontal: 20,
          paddingVertical: 10,
          borderRadius: 8,
        },
        retryButtonText: {
          color: "#fff",
          fontSize: 16,
          fontWeight: "bold",
        },
        videoItem: {
          width: screenDimensions.width,
          height: screenDimensions.height,
        },
      }),
    [screenDimensions.width, screenDimensions.height]
  );

  // Render single video item
  const renderVideoItem = useCallback(
    ({ item, index }: { item: DramaEpisode; index: number }) => {
      // Only render items within 2 positions of currentIndex
      if (Math.abs(index - currentIndex) >= 2) {
        // Render empty view for items far from current
        return <View style={[styles.videoItem]} />;
      }
      return (
        <View style={[styles.videoItem]}>
          <EpisodePlayer
            episode={item}
            dramaTitle={dramaTitle}
            dramaCoverUrl={dramaCoverUrl}
            startTime={
              episodeOrder && index === episodeOrder - 1 ? startTime : 0
            }
            episodes={episodes}
            currentEpisodeIndex={currentIndex}
            playerIndex={index}
            onPlayPause={handlePlayPause}
            onEpisodeSelectorPress={handleEpisodeSelectorPress}
            onRecommendationPress={() => {}}
            dramaId={dramaId}
            playbackSpeed={playbackSpeed}
            onSpeedChange={setPlaybackSpeed}
            dramaVideoOrientation={dramaVideoOrientation}
            onEpisodeSelect={handleEpisodeSelect}
            shouldTriggerScrollPreRender={shouldTriggerScrollPreRender}
            onFullscreen={handleFullscreenFreeze}
            onDidFinish={handleVideoFinish}
            onError={(error) => {
              console.error(`Episode ${index} error:`, error);
            }}
          />
        </View>
      );
    },
    [
      currentIndex,
      styles.videoItem,
      dramaTitle,
      dramaCoverUrl,
      episodeOrder,
      startTime,
      episodes,
      handlePlayPause,
      handleEpisodeSelectorPress,
      dramaId,
      playbackSpeed,
      dramaVideoOrientation,
      handleEpisodeSelect,
      shouldTriggerScrollPreRender,
      handleFullscreenFreeze,
      handleVideoFinish,
    ]
  );

  if (loading) {
    return (
      <View
        style={[
          styles.loadingContainer,
          { paddingTop: insets.top, paddingBottom: insets.bottom },
        ]}
      >
        <ActivityIndicator size="large" color="#1664FF" />
        <Text style={styles.loadingText}>Loading episodes...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View
        style={[
          styles.loadingContainer,
          { paddingTop: insets.top, paddingBottom: insets.bottom },
        ]}
      >
        <Text style={styles.errorText}>Error: {error}</Text>
        <TouchableOpacity onPress={fetchEpisodes} style={styles.retryButton}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {
        <View style={[styles.titleBar, { top: insets.top }]}>
          <TouchableOpacity onPress={handleBackPress} style={styles.backButton}>
            <Image
              source={require("@/assets/images/back_arrow.png")}
              style={styles.backIcon}
            />
          </TouchableOpacity>
          <Text style={styles.titleText} numberOfLines={1}>
            {dramaTitle}
          </Text>
        </View>
      }

      <FlatList
        ref={flashListRef}
        data={episodes}
        renderItem={renderVideoItem}
        initialScrollIndex={episodeOrder - 1}
        keyExtractor={(item: DramaEpisode) => item.vid}
        extraData={{ currentIndex, episodes }}
        getItemLayout={(data, index) => ({
          length: screenDimensions.height,
          offset: screenDimensions.height * index,
          index,
        })}
        snapToInterval={screenDimensions.height}
        showsVerticalScrollIndicator={false}
        snapToAlignment="start"
        decelerationRate="fast"
        disableIntervalMomentum={true}
        bounces={false}
        overScrollMode="never"
        viewabilityConfigCallbackPairs={viewabilityConfigCallbackPairs}
        onScrollBeginDrag={handleScrollBeginDrag}
        onScrollEndDrag={handleScrollEndDrag}
        onMomentumScrollEnd={handleMomentumScrollEnd}
        pagingEnabled={!isTransitioningOrientation}
        removeClippedSubviews={!isTransitioningOrientation}
        scrollEnabled={!isLandscape}
        scrollEventThrottle={16}
      />

      {/* Episode Selector Modal */}
      <EpisodeSelectorModal
        episodes={episodes}
        currentEpisodeIndex={currentIndex}
        onEpisodeSelect={handleEpisodeSelect}
        visible={showEpisodeSelector}
        onClose={() => setShowEpisodeSelector(false)}
        dramaTitle={dramaTitle}
        dramaCoverUrl={dramaCoverUrl}
        dramaId={dramaId}
        onEpisodeUnlocked={handleEpisodeUnlocked}
        onUnlockAllPress={() => {
          // Close other modals
          setShowEpisodeSelector(false);
          setShowVipModal(false);
          // Show unlock all episodes modal
          setShowUnlockMultiple(true);
        }}
      />

      {/* VIP Unlock Modal */}
      <VipUnlockModal
        visible={showVipModal}
        onClose={() => setShowVipModal(false)}
        onWatchAd={handleVipUnlock}
        onUnlockAll={() => {
          // Close VIP modal
          setShowVipModal(false);
          // Show unlock all episodes modal
          setShowUnlockMultiple(true);
        }}
        episodeNumber={currentIndex + 1}
        dramaId={dramaId}
        episodeVid={episodes[currentIndex]?.vid || ""}
      />

      {/* Unlock Multiple Episodes Modal */}
      <UnlockMultipleModal
        visible={showUnlockMultiple}
        onClose={() => {
          setShowUnlockMultiple(false);
          // After closing, if current episode is VIP, show VIP modal again
          if (episodes.length > 0 && episodes[currentIndex]?.vip) {
            setTimeout(() => {
              setShowVipModal(true);
            }, 100);
          }
        }}
        onUnlockSuccess={handleUnlockMultipleSuccess}
        dramaTitle={dramaTitle}
        dramaCoverUrl={dramaCoverUrl}
        allEpisodes={episodes.map((ep) => ({ vid: ep.vid, vip: ep.vip }))}
        dramaId={dramaId}
      />
    </View>
  );
}
