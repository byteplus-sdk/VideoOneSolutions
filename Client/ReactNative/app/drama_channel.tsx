// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useRef, useCallback, useMemo } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  Dimensions,
  FlatList,
} from "react-native";
import { Image } from "expo-image";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { getImageAsset } from "../utils/imageUtils";

import { useRouter } from "expo-router";
import { DramaChannelMeta, FeedItem, DramaEpisode } from "@/types/drama";
import {
  DramaCarousel,
  DramaList,
  VideoPlayer,
  FeedCard,
  FeedInfoPanel,
  RecommendationOverlay,
} from "../components";
import { useDramaChannel } from "@/hooks/useDramaChannel";
import { DramaService } from "@/services/dramaService";
import { setStrategyList } from "@/utils/dramaUtils";
import {
  setPreRenderCallback,
  TTVideoEngine,
  VideoSource,
} from "../utils/playerConfig";

const { height } = Dimensions.get("window");
const { width: screenWidth } = Dimensions.get("window");

const TAB_BAR_HEIGHT = 80;

const DramaChannel = () => {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const [currentTab, setCurrentTab] = useState(0);

  // Content area now fills the screen minus bottom safe area
  // Feed container height is screen height minus bottom safe area and tab bar height

  const {
    data: dramaData,
    loading,
    error,
    refresh,
    hasData,
  } = useDramaChannel();

  // Feed related state
  const [feedItems, setFeedItems] = useState<FeedItem[]>([]);
  const [feedLoading, setFeedLoading] = useState(false);
  const [feedError, setFeedError] = useState<string | null>(null);
  const [currentFeedIndex, setCurrentFeedIndex] = useState(0);
  const [scrollStartY, setScrollStartY] = useState(0);
  const suppressViewabilityRef = useRef(false);
  const [showRecommendationOverlay, setShowRecommendationOverlay] =
    useState(false);
  const [shouldTriggerScrollPreRender, setShouldTriggerScrollPreRender] =
    useState(false);
  const hasTriggeredPreRender = useRef(false);
  const currentVideoTimeRef = useRef(0);

  const flashListRef = useRef<any>(null);

  const handleTabChange = (index: number) => {
    setCurrentTab(index);

    // When switching to feed tab, get feed data
    if (index === 1 && feedItems.length === 0) {
      fetchFeedData();
    }
  };

  // Get Feed data
  const fetchFeedData = useCallback(async () => {
    try {
      setFeedLoading(true);
      setFeedError(null);

      const feedData = await DramaService.getDramaFeed(20);
      setFeedItems(feedData);
      const videoList = feedData.map((item) => item.video_meta);
      setStrategyList(videoList);
      setPreRenderCallback({
        onPlayerCreated(player: TTVideoEngine, source: VideoSource) {
          const vid = source.vid();
          console.log("EngineStrategy: onPlayerCreated vid", vid);
          console.log(
            "EngineStrategy: onPlayerCreated videoList",
            videoList.map((item) => item.vid)
          );
          const targetIndex = videoList.findIndex((item) => item.vid === vid);
          if (targetIndex !== -1) {
            console.log("EngineStrategy: onPlayerCreated index", targetIndex);
          }
        },
      });
    } catch (err) {
      console.error("Failed to fetch feed data:", err);
      setFeedError(
        err instanceof Error ? err.message : "Failed to load feed data"
      );
    } finally {
      setFeedLoading(false);
    }
  }, []);

  // Handle progress update
  const handleProgress = useCallback((progress: number) => {
    currentVideoTimeRef.current = progress;
  }, []);

  // Create viewability config callback pairs
  const viewabilityConfigCallbackPairs = useMemo(
    () => [
      {
        viewabilityConfig: {
          itemVisiblePercentThreshold: 80,
          minimumViewTime: 300,
          waitForInteraction: false,
        },
        onViewableItemsChanged: ({ viewableItems }: any) => {
          if (suppressViewabilityRef.current) return;
          if (viewableItems.length > 0) {
            const newIndex = viewableItems[0].index;
            setCurrentFeedIndex((prevIndex) => {
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

  // Handle scroll distance limit
  const handleScrollBeginDrag = useCallback((event: any) => {
    setScrollStartY(event.nativeEvent.contentOffset.y);
    hasTriggeredPreRender.current = false; // Reset trigger flag when starting new scroll
  }, []);

  const handleScrollEndDrag = useCallback((event: any) => {
    setShouldTriggerScrollPreRender(false);
  }, []);

  // Handle scroll event to detect downward scrolling
  const handleScroll = useCallback(
    (event: any) => {
      const currentScrollY = event.nativeEvent.contentOffset.y;
      const scrollDistance = Math.abs(currentScrollY - scrollStartY);
      const isScrollingDown = currentScrollY > scrollStartY;

      // Trigger scroll pre-render when scrolling down more than 50px, but only once per scroll gesture
      if (
        isScrollingDown &&
        scrollDistance > 50 &&
        !hasTriggeredPreRender.current
      ) {
        setShouldTriggerScrollPreRender(true);
        hasTriggeredPreRender.current = true; // Mark as triggered for this scroll gesture
      }
    },
    [scrollStartY]
  );

  const handleFullscreenFreeze = useCallback(() => {
    suppressViewabilityRef.current = true;
    setTimeout(() => {
      if (flashListRef.current) {
        flashListRef.current.scrollToIndex({
          index: currentFeedIndex,
          animated: false,
        });
      }
      suppressViewabilityRef.current = false;
    }, 500);
  }, [currentFeedIndex]);

  // Ensure at most one item moves per gesture and snap to start (Feed list)
  const handleMomentumScrollEnd = useCallback(
    (event: any) => {
      const offsetY = event.nativeEvent.contentOffset.y;
      const itemHeight = height - TAB_BAR_HEIGHT;
      const intendedIndex = Math.round(offsetY / itemHeight);
      const minIndex = Math.max(0, currentFeedIndex - 1);
      const maxIndex = Math.min(feedItems.length - 1, currentFeedIndex + 1);
      const clampedIndex = Math.max(
        minIndex,
        Math.min(maxIndex, intendedIndex)
      );

      if (clampedIndex !== intendedIndex) {
        if (flashListRef.current) {
          flashListRef.current.scrollToIndex({
            index: clampedIndex,
            animated: true,
          });
        }
      }
    },
    [currentFeedIndex, feedItems.length]
  );

  // Handle card click
  const handleCardPress = useCallback(
    (feedItem: FeedItem) => {
      const { drama_meta, video_meta } = feedItem;

      // Navigate to drama_player page with necessary parameters
      router.push({
        pathname: "/drama_player",
        params: {
          dramaId: drama_meta.drama_id,
          dramaTitle: drama_meta.drama_title,
          dramaCoverUrl: drama_meta.drama_cover_url,
          episodeOrder: video_meta.order.toString(),
          dramaVideoOrientation: drama_meta.drama_video_orientation.toString(),
          startTime: currentVideoTimeRef.current.toString(), // Pass current playback time
        },
      });
    },
    [router]
  );

  // Convert FeedItem to DramaEpisode format
  const convertFeedItemToEpisode = useCallback(
    (feedItem: FeedItem): DramaEpisode => {
      const { video_meta } = feedItem;

      return {
        vid: video_meta.vid,
        drama_id: video_meta.drama_id,
        caption: video_meta.caption,
        duration: video_meta.duration,
        cover_url: video_meta.cover_url,
        video_model: video_meta.video_model,
        play_times: video_meta.play_times,
        subtitle: video_meta.subtitle,
        create_time: video_meta.create_time,
        name: video_meta.name,
        uid: video_meta.uid,
        like: video_meta.like,
        comment: video_meta.comment,
        height: video_meta.height,
        width: video_meta.width,
        order: video_meta.order,
        display_type: video_meta.display_type,
        subtitle_auth_token: video_meta.subtitle_auth_token,
        vip: video_meta.vip,
      };
    },
    []
  );

  // Render single feed video item
  const renderFeedVideoItem = useCallback(
    ({ item, index }: { item: FeedItem; index: number }) => {
      // Only render items within 2 positions of currentFeedIndex
      if (Math.abs(index - currentFeedIndex) >= 2) {
        // Render empty view for items far from current
        return (
          <View
            style={[styles.feedVideoItem, { height: height - TAB_BAR_HEIGHT }]}
          />
        );
      }

      const episode = convertFeedItemToEpisode(item);
      return (
        <View
          style={[styles.feedVideoItem, { height: height - TAB_BAR_HEIGHT }]}
        >
          <VideoPlayer
            episode={episode}
            dramaTitle={item.drama_meta.drama_title}
            dramaCoverUrl={item.drama_meta.drama_cover_url}
            currentIndex={currentFeedIndex}
            episodes={[episode]}
            currentEpisodeIndex={0}
            playerIndex={index}
            onProgress={handleProgress}
            dramaId={item.drama_meta.drama_id}
            dramaVideoOrientation={item.drama_meta.drama_video_orientation}
            isFeedTab={true}
            shouldTriggerScrollPreRender={shouldTriggerScrollPreRender}
            onFullscreen={handleFullscreenFreeze}
            onError={(error) => {
              console.error(`Feed Episode ${index} error:`, error);
            }}
          />

          {item.video_meta.display_type === 1 ? (
            // display_type = 1: Show card
            <FeedCard feedItem={item} onPress={handleCardPress} />
          ) : (
            // display_type = 0: Show info panel
            <FeedInfoPanel feedItem={item} onPress={handleCardPress} />
          )}
        </View>
      );
    },
    [
      currentFeedIndex,
      convertFeedItemToEpisode,
      handleProgress,
      shouldTriggerScrollPreRender,
      handleFullscreenFreeze,
      handleCardPress,
    ]
  );

  const handleBackPress = () => {
    // Return to home page
    router.push("/");
  };

  const handleDramaPress = (drama: DramaChannelMeta) => {
    // Navigate to player page
    router.push({
      pathname: "/drama_player",
      params: {
        dramaId: drama.dramaId,
        dramaTitle: drama.dramaTitle,
        dramaCoverUrl: drama.dramaCoverUrl,
        dramaVideoOrientation: drama.dramaVideoOrientation.toString(),
      },
    } as any);
  };

  const handleRetry = async () => {
    await refresh();
  };

  if (loading) {
    return (
      <View
        style={[
          styles.loadingContainer,
          { paddingTop: insets.top, paddingBottom: insets.bottom },
        ]}
      >
        <ActivityIndicator size="large" color="#1664FF" />
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View
        style={[
          styles.errorContainer,
          { paddingTop: insets.top, paddingBottom: insets.bottom },
        ]}
      >
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={handleRetry}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top }]}>
        <TouchableOpacity onPress={handleBackPress} style={styles.backButton}>
          <Image source={getImageAsset("back_arrow")} style={styles.backIcon} />
        </TouchableOpacity>
        <View style={styles.headerRight} />
      </View>

      {/* Content Area */}
      <View style={[styles.content, { height: height }]}>
        {currentTab === 0 ? (
          <ScrollView
            style={[styles.scrollView, { paddingTop: insets.top }]}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={styles.scrollContent}
          >
            {/* Carousel */}
            {dramaData.loop.length > 0 && (
              <View style={styles.carouselContainer}>
                <DramaCarousel
                  data={dramaData.loop}
                  onItemPress={handleDramaPress}
                />
              </View>
            )}

            {/* Trending Recommendations */}
            {dramaData.trending.length > 0 && (
              <DramaList
                data={dramaData.trending}
                onItemPress={handleDramaPress}
                type="trending"
              />
            )}

            {/* New Releases */}
            {dramaData.new.length > 0 && (
              <DramaList
                data={dramaData.new}
                onItemPress={handleDramaPress}
                type="new"
              />
            )}

            {/* Recommendation List */}
            {dramaData.recommend.length > 0 && (
              <DramaList
                data={dramaData.recommend}
                onItemPress={handleDramaPress}
                type="recommend"
              />
            )}

            {/* Empty State */}
            {!hasData && (
              <View style={styles.emptyContainer}>
                <Text style={styles.emptyText}>No content available</Text>
                <TouchableOpacity
                  style={styles.refreshButton}
                  onPress={handleRetry}
                >
                  <Text style={styles.refreshButtonText}>Refresh</Text>
                </TouchableOpacity>
              </View>
            )}
          </ScrollView>
        ) : (
          <View style={[styles.feedContainer, { height: height }]}>
            {feedLoading ? (
              <View style={styles.feedLoadingContainer}>
                <ActivityIndicator size="large" color="#1664FF" />
                <Text style={styles.feedLoadingText}>Loading feed...</Text>
              </View>
            ) : feedError ? (
              <View style={styles.feedErrorContainer}>
                <Text style={styles.feedErrorText}>Error: {feedError}</Text>
                <TouchableOpacity
                  onPress={fetchFeedData}
                  style={styles.feedRetryButton}
                >
                  <Text style={styles.feedRetryButtonText}>Retry</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <FlatList
                ref={flashListRef}
                data={feedItems}
                renderItem={renderFeedVideoItem}
                keyExtractor={(item: FeedItem) => item.video_meta.vid}
                pagingEnabled
                viewabilityConfigCallbackPairs={viewabilityConfigCallbackPairs}
                onScrollBeginDrag={handleScrollBeginDrag}
                onScrollEndDrag={handleScrollEndDrag}
                onScroll={handleScroll}
                onMomentumScrollEnd={handleMomentumScrollEnd}
                scrollEventThrottle={16}
                showsVerticalScrollIndicator={false}
                getItemLayout={(data, index) => ({
                  length: height - TAB_BAR_HEIGHT,
                  offset: (height - TAB_BAR_HEIGHT) * index,
                  index,
                })}
                snapToInterval={height - TAB_BAR_HEIGHT}
                snapToAlignment="start"
                decelerationRate="fast"
                bounces={false}
                overScrollMode="never"
                disableIntervalMomentum={true}
                disableScrollViewPanResponder={false}
                extraData={{
                  currentFeedIndex,
                  feedItems,
                  shouldTriggerScrollPreRender,
                }}
              />
            )}

            {/* Recommendation Control - Only shown on feed tab with data, positioned above bottom tab */}
            {currentTab === 1 && feedItems.length > 0 && (
              <View style={[styles.recommendationControl]}>
                <TouchableOpacity
                  style={styles.recommendationButton}
                  onPress={() => setShowRecommendationOverlay(true)}
                >
                  <Image
                    source={getImageAsset("recommend")}
                    style={styles.recommendationIcon}
                  />
                  <Text style={styles.recommendationText}>
                    Recommend for you
                  </Text>
                  <Text style={styles.dotText}>·</Text>
                  <Text style={styles.videoCountText}>
                    {feedItems.length} videos
                  </Text>
                  <Image
                    source={getImageAsset("arrow_right")}
                    style={styles.arrowIcon}
                  />
                </TouchableOpacity>
              </View>
            )}
          </View>
        )}

        {/* Bottom Tab Bar */}
        <View style={[styles.tabBar]}>
          <View style={[styles.tabBarContent, { bottom: 0 }]}>
            <TouchableOpacity
              style={styles.tabButton}
              onPress={() => handleTabChange(0)}
            >
              <Image
                source={
                  currentTab === 0
                    ? getImageAsset("drama/homeSelect")
                    : getImageAsset("drama/home")
                }
                style={styles.tabIcon}
              />
              <Text
                style={[
                  styles.tabText,
                  currentTab === 0 && styles.activeTabText,
                ]}
              >
                Home
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.tabButton}
              onPress={() => handleTabChange(1)}
            >
              <Image
                source={
                  currentTab === 1
                    ? getImageAsset("drama/feedSelect")
                    : getImageAsset("drama/feed")
                }
                style={styles.tabIcon}
              />
              <Text
                style={[
                  styles.tabText,
                  currentTab === 1 && styles.activeTabText,
                ]}
              >
                For you
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Recommendation Overlay */}
      <RecommendationOverlay
        visible={showRecommendationOverlay}
        onClose={() => setShowRecommendationOverlay(false)}
        feedItems={feedItems}
        currentVideoIndex={currentFeedIndex}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000",
    position: "relative",
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
  errorContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#000",
    paddingHorizontal: 32,
  },
  errorText: {
    color: "#ff4757",
    fontSize: 16,
    textAlign: "center",
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: "#1664FF",
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  retryButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "500",
  },
  header: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  backButton: {
    padding: 8,
  },
  backIcon: {
    width: 20,
    height: 20,
    tintColor: "#fff",
  },
  headerTitle: {
    color: "#fff",
    fontSize: 18,
    fontWeight: "bold",
  },
  headerRight: {
    width: 40,
  },
  tabBar: {
    zIndex: 1000,
    // backgroundColor: "#000",
    height: TAB_BAR_HEIGHT,
  },
  tabBarContent: {
    zIndex: 1000,
    flexDirection: "row",
    justifyContent: "space-around",
    // backgroundColor: "#000",
    paddingVertical: 8,
    borderTopWidth: 1,
    borderTopColor: "#333",
    height: TAB_BAR_HEIGHT,
    // 添加阴影效果确保完全遮挡
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: -2,
    },
    shadowOpacity: 0.8,
    shadowRadius: 4,
    elevation: 8, // Android阴影
  },
  tabButton: {
    alignItems: "center",
    paddingVertical: 4,
  },
  tabIcon: {
    width: 24,
    height: 24,
  },
  tabText: {
    color: "#888",
    fontSize: 12,
    marginTop: 4,
  },
  activeTabText: {
    color: "#fff",
  },
  content: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 24,
  },
  carouselContainer: {
    marginTop: 20,
    marginBottom: 48,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingVertical: 60,
  },
  emptyText: {
    color: "#888",
    fontSize: 16,
    marginBottom: 16,
  },
  refreshButton: {
    backgroundColor: "#1664FF",
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 6,
  },
  refreshButtonText: {
    color: "#fff",
    fontSize: 14,
    fontWeight: "500",
  },
  recommendationControl: {
    position: "absolute",
    left: 0,
    right: 0,
    bottom: 20,
    zIndex: 1000,
  },
  recommendationButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(7, 8, 10, 0.4)", // Semi-transparent background based on design
    paddingHorizontal: 10,
    paddingVertical: 8,
    marginHorizontal: 0,
  },
  recommendationIcon: {
    width: 16,
    height: 16,
    marginRight: 4,
    tintColor: "#3D3D3D", // Icon color based on design
  },
  recommendationText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    marginRight: 4,
  },
  dotText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    marginRight: 4,
  },
  videoCountText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "500",
    flex: 1,
  },
  arrowIcon: {
    width: 12,
    height: 12,
    tintColor: "#FFFFFF",
  },
  feedContainer: {
    flex: 1,
    backgroundColor: "#000",
    position: "relative",
  },
  feedLoadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#000",
  },
  feedLoadingText: {
    marginTop: 12,
    color: "#fff",
    fontSize: 16,
  },
  feedErrorContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#000",
  },
  feedErrorText: {
    color: "#ff4444",
    fontSize: 16,
    textAlign: "center",
    marginBottom: 20,
  },
  feedRetryButton: {
    backgroundColor: "#1664FF",
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  feedRetryButtonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  feedVideoItem: {
    width: screenWidth,
    flex: 1,
  },
});

export default DramaChannel;
