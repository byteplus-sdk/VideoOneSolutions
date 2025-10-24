// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { Request, API_CONSTANTS } from "./api";
import {
  DramaChannelMeta,
  DramaChannelData,
  DramaApiResponse,
  DramaApiItem,
  DramaEpisode,
  DramaListApiResponse,
  DramaListRequestParams,
  FeedResponse,
  FeedItem,
} from "@/types/drama";
import {
  validateApiResponse,
  validateDramaApiItem,
} from "@/utils/apiTestUtils";

// Drama service class
export class DramaService {
  /**
   * Get drama channel data
   * @returns Promise<DramaChannelData>
   */
  static async getDramaChannel(): Promise<DramaChannelData> {
    try {
      const response = await Request.postRequest<DramaApiResponse>(
        API_CONSTANTS.GET_DRAMA_CHANNEL,
        {}
      );

      // Validate API response
      if (!validateApiResponse(response)) {
        throw new Error("Invalid API response format");
      }

      if (response.code !== 200) {
        throw new Error(`API Error: ${response.message}`);
      }

      const result: DramaChannelData = {
        loop: [],
        trending: [],
        new: [],
        recommend: [],
      };

      // Process carousel data
      if (response.response.loop && Array.isArray(response.response.loop)) {
        result.loop = response.response.loop
          .slice(0, 8) // Limit maximum count to 8
          .filter((item) => validateDramaApiItem(item)) // Filter invalid data
          .map((item) => this.parseDramaMeta(item));
      }

      // Process trending recommendation data
      if (
        response.response.trending &&
        Array.isArray(response.response.trending)
      ) {
        result.trending = response.response.trending
          .filter((item) => validateDramaApiItem(item)) // Filter invalid data
          .map((item) => this.parseDramaMeta(item));
      }

      // Process new drama release data
      if (response.response.new && Array.isArray(response.response.new)) {
        result.new = response.response.new
          .filter((item) => validateDramaApiItem(item)) // Filter invalid data
          .map((item) => this.parseDramaMeta(item));
      }

      // Process recommendation list data
      if (
        response.response.recommend &&
        Array.isArray(response.response.recommend)
      ) {
        result.recommend = response.response.recommend
          .filter((item) => validateDramaApiItem(item)) // Filter invalid data
          .map((item) => this.parseDramaMeta(item));
      }
      return result;
    } catch (error) {
      console.error("Failed to fetch drama channel data:", error);
      throw error;
    }
  }

  /**
   * Parse API returned drama data into DramaChannelMeta object
   * @param item Raw data returned from API
   * @returns DramaChannelMeta
   */
  private static parseDramaMeta(item: DramaApiItem): DramaChannelMeta {
    return {
      dramaId: item.drama_id || "",
      dramaTitle: item.drama_title || "",
      dramaPlayTimes: item.drama_play_times || 0,
      dramaCoverUrl: item.drama_cover_url || "",
      newRelease: item.new_release || false,
      dramaLength: item.drama_length || 0,
      dramaVideoOrientation: item.drama_video_orientation || 0,
    };
  }

  /**
   * Get drama feed data
   * @param pageSize Page size
   * @param pageToken Page token
   * @returns Promise<FeedItem[]>
   */
  static async getDramaFeed(
    pageSize: number = 100,
    pageToken?: string
  ): Promise<FeedItem[]> {
    try {
      const params: any = { page_size: pageSize };
      if (pageToken) {
        params.page_token = pageToken;
      }

      const response = await Request.postRequest<FeedResponse>(
        API_CONSTANTS.GET_DRAMA_FEED,
        params
      );

      // Validate API response
      if (!response || response.code !== 200) {
        throw new Error(`API Error: ${response?.message || "Unknown error"}`);
      }

      if (!Array.isArray(response.response)) {
        throw new Error("Invalid response format: response should be an array");
      }

      console.log(
        `Drama feed fetched successfully, ${response.response.length} items found`
      );
      return response.response;
    } catch (error) {
      console.error("Failed to fetch drama feed:", error);
      throw error;
    }
  }

  /**
   * Get drama list
   * @param params Query parameters
   * @returns Promise<DramaEpisode[]>
   */
  static async getDramaList(
    params: DramaListRequestParams
  ): Promise<DramaEpisode[]> {
    try {
      const response = await Request.postRequest<DramaListApiResponse>(
        API_CONSTANTS.GET_DRAMA_LIST,
        params
      );

      // Validate API response
      if (!response || response.code !== 200) {
        throw new Error(`API Error: ${response?.message || "Unknown error"}`);
      }

      if (!Array.isArray(response.response)) {
        throw new Error("Invalid response format: response should be an array");
      }

      console.log(
        `Drama list fetched successfully, ${response.response.length} episodes found`
      );
      return response.response;
    } catch (error) {
      console.error("Failed to fetch drama list:", error);
      throw error;
    }
  }

  /**
   * Get drama details
   * @param dramaId Drama ID
   * @returns Promise<any>
   */
  static async getDramaDetail(dramaId: string): Promise<any> {
    try {
      const response = await Request.postRequest(API_CONSTANTS.UNLOCK_DRAMA, {
        drama_id: dramaId,
      });
      return response;
    } catch (error) {
      console.error("Failed to fetch drama detail:", error);
      throw error;
    }
  }

  /**
   * Get video comments
   * @param videoId Video ID
   * @param pageSize Page size
   * @param pageToken Page token
   * @returns Promise<any>
   */
  static async getVideoComments(
    videoId: string,
    pageSize: number = 20,
    pageToken?: string
  ): Promise<any> {
    try {
      const params: any = {
        video_id: videoId,
        page_size: pageSize,
      };
      if (pageToken) {
        params.page_token = pageToken;
      }

      const response = await Request.postRequest(
        API_CONSTANTS.GET_VIDEO_COMMENT,
        params
      );
      return response;
    } catch (error) {
      console.error("Failed to fetch video comments:", error);
      throw error;
    }
  }
}

// Export default instance
export default DramaService;
