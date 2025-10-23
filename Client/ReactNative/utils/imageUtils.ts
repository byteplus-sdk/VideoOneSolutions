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
  back_arrow: require("@/assets/images/back_arrow.png"),
  left_arrow: require("@/assets/images/left_arrow.png"),
  arrow_up: require("@/assets/images/up_arrow.png"),
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

  // Drama channel images
  "drama/home": require("@/assets/minidrama/common/home.png"),
  "drama/homeSelect": require("@/assets/minidrama/common/homeSelect.png"),
  "drama/feed": require("@/assets/minidrama/common/feed.png"),
  "drama/feedSelect": require("@/assets/minidrama/common/feedSelect.png"),
  "drama/playButton": require("@/assets/minidrama/common/player/btn_play.png"),

  // Player images
  "player/btn_play": require("@/assets/minidrama/common/player/3x/btn_play.png"),
  "player/fullscreen": require("@/assets/minidrama/common/player/3x/fullscreen.png"),
  "player/v_like": require("@/assets/minidrama/common/player/3x/v_like.png"),
  "player/v_unlike": require("@/assets/minidrama/common/player/3x/v_unlike.png"),
  "player/v_comment": require("@/assets/minidrama/common/player/3x/v_comment.png"),
  "player/series": require("@/assets/minidrama/common/player/3x/series.png"),
  "player/v_speed": require("@/assets/minidrama/common/player/3x/v_speed.png"),
  "player/v_quantity": require("@/assets/minidrama/common/player/3x/v_quantity.png"),

  // Common images
  "common/mute": require("@/assets/minidrama/common/mute.png"),
  "common/comment": require("@/assets/minidrama/common/comment.png"),
  "common/video": require("@/assets/minidrama/common/video.png"),
  "common/series_icon": require("@/assets/minidrama/common/series_icon.png"),
  "common/playing": require("@/assets/minidrama/common/playing.gif"),
  "common/lock": require("@/assets/minidrama/common/lock.png"),
  "common/lock_3x": require("@/assets/minidrama/common/3x/lock.png"),
  "common/like": require("@/assets/minidrama/common/like.png"),
  "common/unlike": require("@/assets/minidrama/common/unlike.png"),

  // Lottie animations
  "lottie/like": require("@/assets/minidrama/lotties/like.json"),
  "lottie/unlike": require("@/assets/minidrama/lotties/unLike.json"),

  // Other images
  recommend: require("@/assets/images/recommend.png"),
  arrow_right: require("@/assets/images/arrow_right.png"),
  right_icon: require("@/assets/images/right_icon.png"),
  not_right_icon: require("@/assets/images/not_right_icon.png"),
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
