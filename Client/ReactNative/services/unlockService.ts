// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { Request, API_CONSTANTS } from "./api";

// Unlock request interface
export interface UnlockRequest {
  drama_id: string;
  vid_list: string[];
}

export interface UnlockEpisodeRequest {
  drama_id: string;
  vid: string;
}

export interface AdUnlockRequest {
  drama_id: string;
  vid: string;
}

export interface UnlockAllRequest {
  drama_id: string;
  vid_list: string[];
}

// Unlock response interface
export interface UnlockResponse {
  vid: string;
  order: number;
  subtitle_auth_token: string;
  video_model: string;
}

export interface UnlockApiResponse {
  code: number;
  message: string;
  response: UnlockResponse[];
}

// Unlock service class
export class UnlockService {
  /**
   * 解锁单个集数（看广告解锁）
   * @param request 广告解锁请求参数
   * @returns Promise<UnlockResponse>
   */
  static async unlockEpisodeByAd(
    request: AdUnlockRequest
  ): Promise<UnlockResponse> {
    try {
      const response = await Request.postRequest<UnlockApiResponse>(
        API_CONSTANTS.UNLOCK_DRAMA,
        {
          drama_id: request.drama_id,
          vid_list: [request.vid],
        }
      );

      // Validate API response
      if (!response || response.code !== 200) {
        throw new Error(`API Error: ${response?.message || "广告解锁失败"}`);
      }

      if (!Array.isArray(response.response) || response.response.length === 0) {
        throw new Error("Invalid response format: response should be an array");
      }

      return response.response[0];
    } catch (error) {
      console.error("Failed to unlock episode by ad:", error);
      throw error;
    }
  }

  /**
   * 解锁单个集数（付费解锁）
   * @param request 付费解锁请求参数
   * @returns Promise<UnlockResponse>
   */
  static async unlockEpisode(
    request: UnlockEpisodeRequest
  ): Promise<UnlockResponse> {
    try {
      const response = await Request.postRequest<UnlockApiResponse>(
        API_CONSTANTS.UNLOCK_DRAMA,
        {
          drama_id: request.drama_id,
          vid_list: [request.vid],
        }
      );

      // Validate API response
      if (!response || response.code !== 200) {
        throw new Error(`API Error: ${response?.message || "付费解锁失败"}`);
      }

      if (!Array.isArray(response.response) || response.response.length === 0) {
        throw new Error("Invalid response format: response should be an array");
      }

      console.log(
        "Episode unlocked successfully by payment:",
        response.response[0]
      );
      return response.response[0];
    } catch (error) {
      console.error("Failed to unlock episode by payment:", error);
      throw error;
    }
  }

  /**
   * 解锁多个集数（付费解锁）
   * @param request 批量解锁请求参数
   * @returns Promise<UnlockResponse[]>
   */
  static async unlockMultipleEpisodes(
    request: UnlockAllRequest
  ): Promise<UnlockResponse[]> {
    try {
      const response = await Request.postRequest<UnlockApiResponse>(
        API_CONSTANTS.UNLOCK_DRAMA,
        request
      );

      // Validate API response
      if (!response || response.code !== 200) {
        throw new Error(`API Error: ${response?.message || "批量解锁失败"}`);
      }

      if (!Array.isArray(response.response)) {
        throw new Error("Invalid response format: response should be an array");
      }

      return response.response;
    } catch (error) {
      console.error("Failed to unlock multiple episodes:", error);
      throw error;
    }
  }
}

// Export default instance (maintain backward compatibility)
export const unlockService = {
  unlockEpisodeByAd: UnlockService.unlockEpisodeByAd,
  unlockEpisode: UnlockService.unlockEpisode,
  unlockMultipleEpisodes: UnlockService.unlockMultipleEpisodes,
};
