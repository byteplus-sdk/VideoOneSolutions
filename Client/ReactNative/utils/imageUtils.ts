// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

// 图片资源映射
export const IMAGE_ASSETS = {
  // Home poster images
  "home/poster/image1": require("@/assets/images/home/poster/image1.png"),
  "home/poster/image2": require("@/assets/images/home/poster/image2.png"),
  "home/poster/image3": require("@/assets/images/home/poster/image3.png"),

  // Home images
  "home/logo": require("@/assets/images/home/logo.png"),
  "home/bg": require("@/assets/images/home/bg.png"),
  "home/loginBg": require("@/assets/images/home/loginBg.png"),
  "home/loginLogo": require("@/assets/images/home/loginLogo.png"),
  "home/back": require("@/assets/images/home/back.png"),

  // Common images
  flutter_logo: require("@/assets/images/flutter_logo.png"),
  icon: require("@/assets/images/icon.png"),
  favicon: require("@/assets/images/favicon.png"),

  // Avatar images
  avatar00: require("@/assets/minidrama/avatars/avatar00.png"),
  avatar01: require("@/assets/minidrama/avatars/avatar01.png"),
  avatar02: require("@/assets/minidrama/avatars/avatar02.png"),
  avatar03: require("@/assets/minidrama/avatars/avatar03.png"),
  avatar04: require("@/assets/minidrama/avatars/avatar04.png"),
  avatar05: require("@/assets/minidrama/avatars/avatar05.png"),
  avatar06: require("@/assets/minidrama/avatars/avatar06.png"),
  avatar07: require("@/assets/minidrama/avatars/avatar07.png"),
  avatar08: require("@/assets/minidrama/avatars/avatar08.png"),
  avatar09: require("@/assets/minidrama/avatars/avatar09.png"),
  avatar10: require("@/assets/minidrama/avatars/avatar10.png"),
  avatar11: require("@/assets/minidrama/avatars/avatar11.png"),
  avatar12: require("@/assets/minidrama/avatars/avatar12.png"),
  avatar13: require("@/assets/minidrama/avatars/avatar13.png"),
  avatar14: require("@/assets/minidrama/avatars/avatar14.png"),
  avatar15: require("@/assets/minidrama/avatars/avatar15.png"),
  avatar16: require("@/assets/minidrama/avatars/avatar16.png"),
  avatar17: require("@/assets/minidrama/avatars/avatar17.png"),
  avatar18: require("@/assets/minidrama/avatars/avatar18.png"),
  avatar19: require("@/assets/minidrama/avatars/avatar19.png"),

  // Lottie animations
  "lottie/like": require("@/assets/minidrama/lotties/like.json"),
  "lottie/unlike": require("@/assets/minidrama/lotties/unLike.json"),
} as const;

export function getImageAsset(path: keyof typeof IMAGE_ASSETS) {
  return IMAGE_ASSETS[path];
}

export function isLocalImagePath(path: string): boolean {
  return (
    path.startsWith("@/assets/") ||
    path.startsWith("./assets/") ||
    path.startsWith("../assets/")
  );
}

export function getImageSource(path: string | keyof typeof IMAGE_ASSETS) {
  if (typeof path === "string") {
    if (isLocalImagePath(path)) {
      const key = path
        .replace("@/assets/", "")
        .replace(".png", "")
        .replace(".jpg", "") as keyof typeof IMAGE_ASSETS;
      return IMAGE_ASSETS[key] || { uri: path };
    }
    return { uri: path };
  }
  return path;
}
