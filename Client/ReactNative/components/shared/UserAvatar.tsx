// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { useState, useEffect } from "react";
import { TouchableOpacity, Alert, StyleSheet } from "react-native";
import { Image } from "expo-image";
import { UserService } from "@/services/userService";
import { getImageAsset } from "../../utils/imageUtils";

// get avatar source
const getAvatarSource = (avatarName: string) => {
  const avatarKey = avatarName.replace(
    ".png",
    ""
  ) as keyof typeof import("../../utils/imageUtils").IMAGE_ASSETS;
  return getImageAsset(avatarKey) || getImageAsset("avatar00");
};

interface UserAvatarProps {
  size?: number;
  onAvatarChange?: (avatar: string) => void;
}

const UserAvatar: React.FC<UserAvatarProps> = ({
  size = 30,
  onAvatarChange,
}) => {
  const [lastTap, setLastTap] = useState<number>(0);
  const [userAvatar, setUserAvatar] = useState<string>("avatar00.png");

  // initialize user avatar
  useEffect(() => {
    const initializeAvatar = async () => {
      try {
        const avatar = await UserService.getUserAvatar();
        setUserAvatar(avatar);
        onAvatarChange?.(avatar);
      } catch (error) {
        console.error("Failed to initialize user avatar:", error);
      }
    };

    initializeAvatar();
  }, [onAvatarChange]);

  const handleAvatarDoubleTap = async () => {
    const now = Date.now();
    const DOUBLE_TAP_DELAY = 300;

    if (lastTap && now - lastTap < DOUBLE_TAP_DELAY) {
      // double tap detected
      Alert.alert(
        "Clear user data",
        "Are you sure you want to clear the current user data? This will reset your user ID and avatar.",
        [
          {
            text: "Cancel",
            style: "cancel",
          },
          {
            text: "Confirm",
            style: "destructive",
            onPress: async () => {
              try {
                await UserService.clearUserData();
                // reinitialize user data
                const avatar = await UserService.getUserAvatar();
                setUserAvatar(avatar);
                onAvatarChange?.(avatar);
                Alert.alert(
                  "Success",
                  "User data has been cleared, a new user ID and avatar will be generated"
                );
              } catch (error) {
                console.error("Failed to clear user data:", error);
                Alert.alert(
                  "Error",
                  "Failed to clear user data, please try again"
                );
              }
            },
          },
        ]
      );
    } else {
      setLastTap(now);
    }
  };

  return (
    <TouchableOpacity onPress={handleAvatarDoubleTap}>
      <Image
        source={getAvatarSource(userAvatar)}
        style={[
          styles.avatar,
          { width: size, height: size, borderRadius: size / 2 },
        ]}
      />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  avatar: {
    // basic style, size and radius are set dynamically by props
  },
});

export default UserAvatar;
