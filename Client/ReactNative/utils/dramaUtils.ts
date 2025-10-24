// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import {
  DramaEpisode,
  IPlayInfoListItem,
  DramaVideoModel,
} from "@/types/drama";
import {
  setStrategySources,
  addStrategySources,
  createDirectUrlSource,
} from "./playerConfig";

export function formatNumber(count: number): string {
  return formatNumberCN(count);
}

export function formatNumberCN(count: number): string {
  if (count > 10000) {
    return `${(count / 10000).toFixed(1)}w`;
  }
  return count.toString();
}

export function formatNumberEN(count: number): string {
  if (count > 1000000) {
    return `${(count / 1000000).toFixed(1)}m`;
  } else if (count > 1000) {
    return `${(count / 1000).toFixed(1)}k`;
  }
  return count.toString();
}

/**
 * Select the best video playback information
 * @param videoModel Video model data
 * @param preferredDefinition Preferred video quality, defaults to "720p"
 * @returns Selected playback info, returns the first one if not found
 */
export function selectBestPlayInfo(
  videoModel: DramaVideoModel,
  preferredDefinition: string = "720p"
): IPlayInfoListItem | null {
  if (!videoModel.PlayInfoList || videoModel.PlayInfoList.length === 0) {
    return null;
  }

  // Prefer the specified video quality
  const preferredQuality = videoModel.PlayInfoList.find(
    (item) => item.Definition === preferredDefinition
  );

  // Return preferred quality if found, otherwise return the first one
  return preferredQuality || videoModel.PlayInfoList[0];
}

/**
 * Parse video model safely with error handling
 * @param videoModelString JSON string of video model
 * @returns Parsed video model or null if parsing fails
 */
function parseVideoModelSafely(
  videoModelString: string
): DramaVideoModel | null {
  try {
    return JSON.parse(videoModelString);
  } catch (error) {
    console.warn("Failed to parse video model:", error);
    return null;
  }
}

/**
 * Create strategy source from drama episode
 * @param episode Drama episode data
 * @param preferredDefinition Preferred video quality
 * @returns Strategy source or null if creation fails
 */
function createStrategySourceFromEpisode(
  episode: DramaEpisode,
  preferredDefinition: string = "720p"
) {
  const videoModel = parseVideoModelSafely(episode.video_model);

  if (!videoModel) {
    console.warn(`Failed to parse video model for episode ${episode.vid}`);
    return null;
  }

  const targetPlayInfo = selectBestPlayInfo(videoModel, preferredDefinition);

  if (!targetPlayInfo) {
    console.warn(`No play info found for episode ${episode.vid}`);
    return null;
  }

  return createDirectUrlSource({
    vid: episode.vid,
    url: targetPlayInfo.MainPlayUrl,
    cacheKey: episode.vid,
  });
}

type AvailableSourceData = Pick<DramaEpisode, 'video_model' | 'vid' | 'vip'>;

/**
 * Process drama episodes list and create strategy sources
 * @param list List of drama episodes
 * @param preferredDefinition Preferred video quality
 * @returns Array of valid strategy sources
 */
function processEpisodesToStrategySources(
  list: AvailableSourceData[],
  preferredDefinition: string = "720p"
) {
  return list
    .filter((item) => !item.vip)
    .map((item) => createStrategySourceFromEpisode(item, preferredDefinition))
    .filter((source): source is NonNullable<typeof source> => source !== null);
}

/**
 * Set strategy list for video playback
 * @param list List of drama episodes
 * @param preferredDefinition Preferred video quality, defaults to "720p"
 */
export function setStrategyList(
  list: AvailableSourceData[],
  preferredDefinition: string = "720p"
) {
  const strategyList = processEpisodesToStrategySources(
    list,
    preferredDefinition
  );

  if (strategyList.length === 0) {
    console.warn("No valid strategy sources found in the provided list");
    return;
  }

  setStrategySources(strategyList);
}

/**
 * Add strategy list to existing video playback sources
 * @param list List of drama episodes
 * @param preferredDefinition Preferred video quality, defaults to "720p"
 */
export function addStrategyList(
  list: AvailableSourceData[],
  preferredDefinition: string = "720p"
) {
  const strategyList = processEpisodesToStrategySources(
    list,
    preferredDefinition
  );

  if (strategyList.length === 0) {
    console.warn("No valid strategy sources found in the provided list");
    return;
  }

  addStrategySources(strategyList);
}
