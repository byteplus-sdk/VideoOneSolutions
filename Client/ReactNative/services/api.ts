// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { UserService } from "./userService";

// API Constants
export const API_CONSTANTS = {
  GET_DRAMA_FEED: "/videoone/drama/v1/getDramaFeed",
  GET_DRAMA_CHANNEL: "/videoone/drama/v1/getDramaChannel",
  GET_VIDEO_COMMENT: "/videoone/drama/v1/getVideoComments",
  GET_DRAMA_LIST: "/videoone/drama/v1/getDramaList",
  UNLOCK_DRAMA: "/videoone/drama/v1/getDramaDetail",
};

// Server Configuration
const SERVER_HOST = "videocloud.byteplusapi.com";

// Request Status Enum
export enum RequestStatus {
  SUCCESS = "SUCCESS",
  FAILED = "FAILED",
}

// Common Constants
export const COMMON_CONSTANTS = {
  DEFAULT_FEED_PAGE_SIZE: 10,
  DEFAULT_PLAY_INFO_TYPE: 1,
  APP_ID: "698142",
  OPEN_DEBUG_LOG: true,
  CACHE_MAX_SIZE: 300 * 1024 * 1024,
};

// Request Utility Class
export class Request {
  static async getRequest<T extends Record<string, any>>(
    path: string,
    params?: Record<string, any>
  ): Promise<T> {
    const url = this.getUrl(path, params);

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (response.ok) {
        const body = (await response.json()) as T;
        return body;
      }

      throw new Error(`GET request error: ${response.status}`);
    } catch (error) {
      console.error(`GET request for path=${path} failed:`, error);
      throw error;
    }
  }

  static async postRequest<T extends Record<string, any>>(
    path: string,
    data: any
  ): Promise<T> {
    const url = this.getUrl(path);

    try {
      // Automatically add user ID and play_info_type to request data
      const userId = await UserService.getUserId();
      const requestData = {
        ...data,
        user_id: userId,
        play_info_type: COMMON_CONSTANTS.DEFAULT_PLAY_INFO_TYPE,
      };

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(requestData),
      });

      if (response.ok) {
        const body = (await response.json()) as T;
        return body;
      }

      console.error(
        `POST request for path=${path} failed, request=${JSON.stringify(
          requestData
        )}, response=`,
        await response.text()
      );
      throw new Error(`POST request error: ${response.status}`);
    } catch (error) {
      console.error(`POST request for path=${path} failed:`, error);
      throw error;
    }
  }

  private static getUrl(path: string, params?: Record<string, any>): string {
    const url = new URL(`https://${SERVER_HOST}${path}`);

    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.append(key, String(value));
      });
    }

    return url.toString();
  }
}
