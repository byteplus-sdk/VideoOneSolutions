// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

import React, { memo } from "react";
import { StyleSheet, type ImageStyle, type StyleProp } from "react-native";
import type { SvgProps } from "react-native-svg";
import CastIcon from "@/assets/icons/cast.svg";
import CheckCircleIcon from "@/assets/icons/check-circle.svg";
import ChevronLeftIcon from "@/assets/icons/chevron-left.svg";
import ChevronRightIcon from "@/assets/icons/chevron-right.svg";
import ChevronUpIcon from "@/assets/icons/chevron-up.svg";
import CloseIcon from "@/assets/icons/close.svg";
import CloseCircleIcon from "@/assets/icons/close-circle.svg";
import CommentIcon from "@/assets/icons/comment.svg";
import CommentOutlineIcon from "@/assets/icons/comment-outline.svg";
import EpisodesIcon from "@/assets/icons/episodes.svg";
import FeedIcon from "@/assets/icons/feed.svg";
import FeedSelectedIcon from "@/assets/icons/feed-selected.svg";
import FireIcon from "@/assets/icons/fire.svg";
import FireColoredIcon from "@/assets/icons/fire-colored.svg";
import FullscreenIcon from "@/assets/icons/fullscreen.svg";
import HeartIcon from "@/assets/icons/heart.svg";
import HeartFilledIcon from "@/assets/icons/heart-filled.svg";
import HeartOutlineIcon from "@/assets/icons/heart-outline.svg";
import HomeIcon from "@/assets/icons/home.svg";
import HomeSelectedIcon from "@/assets/icons/home-selected.svg";
import LockIcon from "@/assets/icons/lock.svg";
import MuteIcon from "@/assets/icons/mute.svg";
import PauseIcon from "@/assets/icons/pause.svg";
import PlayIcon from "@/assets/icons/play.svg";
import QualityIcon from "@/assets/icons/quality.svg";
import RecommendIcon from "@/assets/icons/recommend.svg";
import RefreshIcon from "@/assets/icons/refresh.svg";
import SeriesIcon from "@/assets/icons/series.svg";
import SpeedIcon from "@/assets/icons/speed.svg";

const ICONS = {
  "cast": CastIcon,
  "check-circle": CheckCircleIcon,
  "chevron-left": ChevronLeftIcon,
  "chevron-right": ChevronRightIcon,
  "chevron-up": ChevronUpIcon,
  "close": CloseIcon,
  "close-circle": CloseCircleIcon,
  "comment": CommentIcon,
  "comment-outline": CommentOutlineIcon,
  "episodes": EpisodesIcon,
  "feed": FeedIcon,
  "feed-selected": FeedSelectedIcon,
  "fire": FireIcon,
  "fire-colored": FireColoredIcon,
  "fullscreen": FullscreenIcon,
  "heart": HeartIcon,
  "heart-filled": HeartFilledIcon,
  "heart-outline": HeartOutlineIcon,
  "home": HomeIcon,
  "home-selected": HomeSelectedIcon,
  "lock": LockIcon,
  "mute": MuteIcon,
  "pause": PauseIcon,
  "play": PlayIcon,
  "quality": QualityIcon,
  "recommend": RecommendIcon,
  "refresh": RefreshIcon,
  "series": SeriesIcon,
  "speed": SpeedIcon,
} as const;

export type IconName = keyof typeof ICONS;

interface SvgIconProps extends Omit<SvgProps, "style"> {
  name: IconName;
  style?: StyleProp<ImageStyle>;
}

/** Keep icon layout and tint separate from the vector paths. */
const SvgIcon = memo(function SvgIcon({ name, style, color, ...props }: SvgIconProps) {
  const { tintColor, ...layoutStyle } = StyleSheet.flatten(style) ?? {};
  const Icon = ICONS[name];
  const defaultColor = name === "home" || name === "feed" ? "#B3B3B3" : "#FFFFFF";
  const width =
    typeof layoutStyle.width === "number" || typeof layoutStyle.width === "string"
      ? layoutStyle.width
      : 24;
  const height =
    typeof layoutStyle.height === "number" || typeof layoutStyle.height === "string"
      ? layoutStyle.height
      : 24;

  return (
    <Icon
      accessible={false}
      pointerEvents="none"
      width={width}
      height={height}
      {...props}
      style={layoutStyle}
      color={color ?? tintColor ?? defaultColor}
    />
  );
});

export default SvgIcon;
