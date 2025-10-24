// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import AsyncStorage from "@react-native-async-storage/async-storage";

const USER_ID_KEY = "video_one_user_id";
const USER_AVATAR_KEY = "video_one_user_avatar";

/**
 * User service class - Unified user ID management
 */
export class UserService {
  private static _userId: string | null = null;
  private static _userAvatar: string | null = null;

  /**
   * Get user ID
   * If not in memory, get from AsyncStorage
   * If not in AsyncStorage either, generate a new user ID
   * @returns Promise<string>
   */
  static async getUserId(): Promise<string> {
    try {
      // If user ID already exists in memory, return directly
      if (this._userId) {
        return this._userId;
      }

      // Get user ID from AsyncStorage
      const storedUserId = await AsyncStorage.getItem(USER_ID_KEY);

      if (storedUserId) {
        this._userId = storedUserId;
        return storedUserId;
      }

      // Generate new user ID
      const newUserId = this.generateUserId();
      await this.saveUserId(newUserId);
      return newUserId;
    } catch (error) {
      console.error("Failed to get user ID:", error);
      // If error occurs, generate fallback user ID
      const fallbackUserId = this.generateUserId();
      this._userId = fallbackUserId;
      return fallbackUserId;
    }
  }

  /**
   * Save user ID to AsyncStorage
   * @param userId User ID
   * @returns Promise<void>
   */
  static async saveUserId(userId: string): Promise<void> {
    try {
      await AsyncStorage.setItem(USER_ID_KEY, userId);
      this._userId = userId;
    } catch (error) {
      console.error("Failed to save user ID:", error);
      throw error;
    }
  }

  /**
   * Clear user ID
   * Remove user ID from AsyncStorage and memory
   * @returns Promise<void>
   */
  static async clearUserId(): Promise<void> {
    try {
      await AsyncStorage.removeItem(USER_ID_KEY);
      this._userId = null;
    } catch (error) {
      console.error("Failed to clear user ID:", error);
      throw error;
    }
  }

  /**
   * Clear all user data
   * Remove user ID and avatar from AsyncStorage and memory
   * @returns Promise<void>
   */
  static async clearUserData(): Promise<void> {
    try {
      await Promise.all([
        AsyncStorage.removeItem(USER_ID_KEY),
        AsyncStorage.removeItem(USER_AVATAR_KEY),
      ]);
      this._userId = null;
      this._userAvatar = null;
    } catch (error) {
      console.error("Failed to clear user data:", error);
      throw error;
    }
  }

  /**
   * Generate new user ID
   * @returns string
   */
  private static generateUserId(): string {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 15);
    return `user_${timestamp}_${random}`;
  }

  /**
   * Check if user ID already exists
   * @returns Promise<boolean>
   */
  static async hasUserId(): Promise<boolean> {
    try {
      const storedUserId = await AsyncStorage.getItem(USER_ID_KEY);
      return storedUserId !== null;
    } catch (error) {
      console.error("Failed to check user ID existence:", error);
      return false;
    }
  }

  /**
   * Get current user ID in memory (synchronous method)
   * @returns string | null
   */
  static getCurrentUserId(): string | null {
    return this._userId;
  }

  /**
   * Get user avatar
   * If not in memory, get from AsyncStorage
   * If not in AsyncStorage either, generate a new avatar
   * @returns Promise<string>
   */
  static async getUserAvatar(): Promise<string> {
    try {
      // If user avatar already exists in memory, return directly
      if (this._userAvatar) {
        return this._userAvatar;
      }

      // Get user avatar from AsyncStorage
      const storedAvatar = await AsyncStorage.getItem(USER_AVATAR_KEY);

      if (storedAvatar) {
        this._userAvatar = storedAvatar;
        return storedAvatar;
      }

      // Generate new user avatar
      const newAvatar = this.generateUserAvatar();
      await this.saveUserAvatar(newAvatar);
      return newAvatar;
    } catch (error) {
      console.error("Failed to get user avatar:", error);
      // If error occurs, generate fallback avatar
      const fallbackAvatar = this.generateUserAvatar();
      this._userAvatar = fallbackAvatar;
      return fallbackAvatar;
    }
  }

  /**
   * Save user avatar to AsyncStorage
   * @param avatar Avatar file name
   * @returns Promise<void>
   */
  static async saveUserAvatar(avatar: string): Promise<void> {
    try {
      await AsyncStorage.setItem(USER_AVATAR_KEY, avatar);
      this._userAvatar = avatar;
    } catch (error) {
      console.error("Failed to save user avatar:", error);
      throw error;
    }
  }

  /**
   * Clear user avatar
   * Remove user avatar from AsyncStorage and memory
   * @returns Promise<void>
   */
  static async clearUserAvatar(): Promise<void> {
    try {
      await AsyncStorage.removeItem(USER_AVATAR_KEY);
      this._userAvatar = null;
    } catch (error) {
      console.error("Failed to clear user avatar:", error);
      throw error;
    }
  }

  /**
   * Generate new user avatar
   * Select a fixed avatar based on user ID
   * @returns string
   */
  private static generateUserAvatar(): string {
    // Use user ID hash value to select avatar, ensuring same user always gets same avatar
    const userId = this._userId || this.generateUserId();
    const hash = this.hashString(userId);
    const avatarIndex = Math.abs(hash) % 20; // There are 20 avatar files (avatar00.png to avatar19.png)
    return `avatar${avatarIndex.toString().padStart(2, "0")}.png`;
  }

  /**
   * Simple string hash function
   * @param str Input string
   * @returns number
   */
  private static hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash;
  }

  /**
   * Get current user avatar in memory (synchronous method)
   * @returns string | null
   */
  static getCurrentUserAvatar(): string | null {
    return this._userAvatar;
  }
}

// Export default instance
export default UserService;
