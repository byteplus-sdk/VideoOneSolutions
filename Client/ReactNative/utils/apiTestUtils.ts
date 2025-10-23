// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import { DramaApiItem } from "@/types/drama";

// Validate API data structure
export function validateApiResponse(response: any): boolean {
  try {
    // Check basic structure
    if (!response || typeof response !== "object") {
      console.error("Invalid response: not an object");
      return false;
    }

    if (response.code !== 200) {
      console.error("API error:", response.message);
      return false;
    }

    if (!response.response || typeof response.response !== "object") {
      console.error("Invalid response: missing response field");
      return false;
    }

    // Check each data array
    const requiredArrays = ["loop", "trending", "new", "recommend"];
    for (const arrayName of requiredArrays) {
      if (!Array.isArray(response.response[arrayName])) {
        console.error(`Invalid response: ${arrayName} is not an array`);
        return false;
      }
    }

    // Validate structure of each data item
    for (const arrayName of requiredArrays) {
      const items = response.response[arrayName];
      for (const item of items) {
        if (!validateDramaApiItem(item)) {
          console.error(`Invalid item in ${arrayName}:`, item);
          return false;
        }
      }
    }

    console.log("API response validation passed");
    return true;
  } catch (error) {
    console.error("Validation error:", error);
    return false;
  }
}

// Validate single API data item
export function validateDramaApiItem(item: any): item is DramaApiItem {
  const requiredFields = [
    "drama_id",
    "drama_title",
    "drama_play_times",
    "drama_cover_url",
    "new_release",
    "drama_length",
    "drama_video_orientation",
  ];

  for (const field of requiredFields) {
    if (!(field in item)) {
      console.error(`Missing required field: ${field}`);
      return false;
    }
  }

  // Type checking
  if (typeof item.drama_id !== "string" || !item.drama_id) {
    console.error("Invalid drama_id");
    return false;
  }

  if (typeof item.drama_title !== "string" || !item.drama_title) {
    console.error("Invalid drama_title");
    return false;
  }

  if (typeof item.drama_play_times !== "number" || item.drama_play_times < 0) {
    console.error("Invalid drama_play_times");
    return false;
  }

  if (typeof item.drama_cover_url !== "string" || !item.drama_cover_url) {
    console.error("Invalid drama_cover_url");
    return false;
  }

  if (typeof item.new_release !== "boolean") {
    console.error("Invalid new_release");
    return false;
  }

  if (typeof item.drama_length !== "number" || item.drama_length < 0) {
    console.error("Invalid drama_length");
    return false;
  }

  if (
    typeof item.drama_video_orientation !== "number" ||
    ![0, 1].includes(item.drama_video_orientation)
  ) {
    console.error("Invalid drama_video_orientation");
    return false;
  }

  return true;
}
