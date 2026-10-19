// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.media.MediaPlayer;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.utils.L;
import com.ss.ttvideoengine.TTVideoEngine;
import com.ss.ttvideoengine.TTVideoEngineMasterPlaylist;
import com.ss.ttvideoengine.TTVideoEngineMasterPlaylist.TTVideoEngineRendition;
import com.ss.ttvideoengine.TTVideoEngineMasterPlaylist.TTVideoEngineVariantStream;
import com.ss.ttvideoengine.TTVideoEnginePlayHLSChooseStreamCallback;
import com.ss.ttvideoengine.TTVideoEnginePreloadHLSChooseUrlCallback.TTVideoEnginePreloadUrlInfo;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Opt-in fixed startup selection for standard Master M3U8 URL sources.
 * The SDK preload callback is global: configure once, after SDK initialization and
 * before creating tasks/players. Do not combine this policy with Master M3U8 ABR
 * or another global preload callback. Disabled by default.
 */
@SuppressWarnings("deprecation")
public final class VolcHlsSelectionStrategy {
    public static final int DEFAULT_SHORT_SIDE = 480;
    public static final int DEFAULT_PRELOAD_BYTES = 800 * 1024;
    private static final int AUDIO_BUDGET_DIVISOR = 5;
    private static final int SDK_DEFAULT = -1;

    private static volatile Policy sPolicy;

    private VolcHlsSelectionStrategy() {}

    public static synchronized void enable(int targetShortSide, String audioLanguage, int preloadBytes) {
        if (targetShortSide <= 0 || empty(audioLanguage) || preloadBytes < AUDIO_BUDGET_DIVISOR) {
            throw new IllegalArgumentException("Resolution, audio language and preload budget required");
        }
        final Policy policy = new Policy(targetShortSide, audioLanguage, preloadBytes);
        TTVideoEngine.setPreloadChooseUrlCallback(master -> chooseUrls(master, policy));
        sPolicy = policy;
    }

    /** Call after stopping existing tasks/players; restores the SDK preload selector. */
    public static synchronized void disable() {
        if (sPolicy == null)
            return;
        sPolicy = null;
        TTVideoEngine.setPreloadChooseUrlCallback(null);
    }

    public static void setup(TTVideoEngine engine, MediaSource source) {
        final Policy policy = sPolicy;
        if (policy == null || source == null || source.getSourceType() != MediaSource.SOURCE_TYPE_URL
            || source.isSupportABR() || VolcQualityStrategy.isEnableABR(VolcConfig.get(source))
            || VolcQualityStrategy.isEnableStartupABR(VolcConfig.get(source))
            || source.getMediaType() != MediaSource.MEDIA_TYPE_VIDEO) {
            return;
        }
        engine.setPlayerHLSChooseStreamCallback(new TTVideoEnginePlayHLSChooseStreamCallback() {
            private TTVideoEngineMasterPlaylist playlist;
            private int selectedIndex = SDK_DEFAULT;

            @Override
            public void streamInfos(TTVideoEngineMasterPlaylist masterPlaylist) {
                playlist = masterPlaylist;
                selectedIndex = chooseVariant(masterPlaylist, policy);
            }

            @Override
            public int chooseVariantBandWidth() {
                if (selectedIndex == SDK_DEFAULT)
                    return SDK_DEFAULT;
                return playlist.variantStreams[selectedIndex].bandwidth;
            }

            @Override
            public int chooseRenditionInfoId(int variantIndex) {
                if (selectedIndex == SDK_DEFAULT)
                    return SDK_DEFAULT;
                // 内核传回实际选中的档位；音轨必须属于该档位，不能跨组匹配语言。
                TTVideoEngineRendition audio = chooseAudio(playlist, variantIndex, policy, true);
                return audio == null ? SDK_DEFAULT : audio.infoId;
            }
        });
    }

    private static List<TTVideoEnginePreloadUrlInfo> chooseUrls(TTVideoEngineMasterPlaylist master, Policy policy) {
        int index = chooseVariant(master, policy);
        if (index == SDK_DEFAULT)
            return null; // null 恢复 SDK 默认策略，不表示取消任务。
        TTVideoEngineVariantStream video = master.variantStreams[index];
        TTVideoEngineRendition audio = chooseAudio(master, index, policy, false);
        // 声明了外置音轨却无法找到对应组时，整项降级，避免只预加载无声视频。
        if (!empty(video.audioGroupId) && audio == null)
            return null;
        int audioBytes = audio != null && !empty(audio.uri) && !audio.uri.equals(video.uri)
            ? policy.preloadBytes / AUDIO_BUDGET_DIVISOR
            : 0;
        List<TTVideoEnginePreloadUrlInfo> urls = new ArrayList<>();
        urls.add(url(video.uri, policy.preloadBytes - audioBytes));
        if (audioBytes > 0)
            urls.add(url(audio.uri, audioBytes));
        L.d(VolcHlsSelectionStrategy.class, "preloadSelection", "resolution", video.resolution, "bandwidth",
            video.bandwidth, "audioLanguage", audio == null ? "" : audio.language, "budget", policy.preloadBytes);
        return urls;
    }

    private static TTVideoEnginePreloadUrlInfo url(String uri, int bytes) {
        TTVideoEnginePreloadUrlInfo info = new TTVideoEnginePreloadUrlInfo();
        info.uri = uri;
        info.preloadSize = bytes;
        return info;
    }

    private static int chooseVariant(TTVideoEngineMasterPlaylist master, Policy policy) {
        if (master == null || master.variantStreams == null)
            return SDK_DEFAULT;
        int selected = SDK_DEFAULT;
        int selectedSide = 0;
        for (int i = 0; i < master.variantStreams.length; i++) {
            TTVideoEngineVariantStream candidate = master.variantStreams[i];
            if (candidate == null || empty(candidate.uri) || candidate.bandwidth <= 0 || !compatible(candidate.codecs))
                continue;
            int side = shortSide(candidate.resolution);
            if (side <= 0)
                continue;
            if (!empty(candidate.audioGroupId) && chooseAudio(master, i, policy, false) == null
                && chooseAudio(master, i, policy, true) == null)
                continue;
            // 选择不超过目标的最大档；若所有档都更高，选择最低档。
            // 同分辨率优先低码率，避免 AAC/AC3 等重复档位导致两条链路选流不一致。
            if (selected == SDK_DEFAULT
                || (side <= policy.shortSide && (selectedSide > policy.shortSide || side > selectedSide))
                || (side > policy.shortSide && selectedSide > policy.shortSide && side < selectedSide)
                || (side == selectedSide && candidate.bandwidth < master.variantStreams[selected].bandwidth)) {
                selected = i;
                selectedSide = side;
            }
        }
        // 播放回调只能返回 BANDWIDTH；重复值无法唯一定位档位，整项交回 SDK。
        if (selected != SDK_DEFAULT) {
            int bandwidth = master.variantStreams[selected].bandwidth;
            for (int i = 0; i < master.variantStreams.length; i++) {
                if (i != selected && master.variantStreams[i] != null
                    && master.variantStreams[i].bandwidth == bandwidth)
                    return SDK_DEFAULT;
            }
        }
        return selected;
    }

    private static TTVideoEngineRendition chooseAudio(
        TTVideoEngineMasterPlaylist master, int index, Policy policy, boolean playback) {
        if (master == null || master.variantStreams == null || master.renditions == null || index < 0
            || index >= master.variantStreams.length || master.variantStreams[index] == null)
            return null;
        String group = master.variantStreams[index].audioGroupId;
        if (empty(group))
            return null;
        TTVideoEngineRendition selected = null;
        int bestRank = -1;
        for (TTVideoEngineRendition audio : master.renditions) {
            if (audio == null || !group.equals(audio.groupId))
                continue;
            // Player 回调的 type/uri/default 未透传；用 trackType 和 variantIndex 识别音轨。
            if (playback) {
                if (audio.trackType != MediaPlayer.TrackInfo.MEDIA_TRACK_TYPE_AUDIO || audio.variantIndex != index)
                    continue;
            } else if (!"AUDIO".equalsIgnoreCase(audio.type)) {
                continue;
            }
            int rank = languageRank(audio.language, policy.language);
            // 转换后的播放回调没有 DEFAULT 标记；语言缺失时交给 SDK，避免两端回退不一致。
            if (!empty(policy.language) && rank == 0)
                continue;
            if (rank > bestRank) {
                selected = audio;
                bestRank = rank;
            }
        }
        return selected;
    }

    private static int languageRank(String language, String preferred) {
        if (empty(language) || empty(preferred))
            return 0;
        String normalized = language.toLowerCase(Locale.ROOT).replace('_', '-');
        if (normalized.equals(preferred))
            return 4;
        int languageSeparator = normalized.indexOf('-');
        int preferredSeparator = preferred.indexOf('-');
        String languageBase = languageSeparator < 0 ? normalized : normalized.substring(0, languageSeparator);
        String preferredBase = preferredSeparator < 0 ? preferred : preferred.substring(0, preferredSeparator);
        return !languageBase.isEmpty() && languageBase.equals(preferredBase) ? 2 : 0;
    }

    private static boolean compatible(String codecs) {
        if (empty(codecs))
            return false;
        String normalized = codecs.toLowerCase(Locale.ROOT);
        // 测试策略只处理明确声明的 AVC/AAC，其他编码交给 SDK 的能力判断。
        if (!normalized.contains("avc1") && !normalized.contains("avc3"))
            return false;
        for (String codec : normalized.split(",")) {
            String value = codec.trim();
            if (!value.startsWith("avc1") && !value.startsWith("avc3") && !value.startsWith("mp4a.40."))
                return false;
        }
        return true;
    }

    private static int shortSide(String resolution) {
        if (empty(resolution))
            return 0;
        String[] dimensions = resolution.toLowerCase(Locale.ROOT).split("x");
        if (dimensions.length != 2)
            return 0;
        try {
            return Math.min(Integer.parseInt(dimensions[0].trim()), Integer.parseInt(dimensions[1].trim()));
        } catch (NumberFormatException ignored) {
            return 0;
        }
    }

    private static boolean empty(String value) {
        return value == null || value.isEmpty();
    }

    private static final class Policy {
        final int shortSide;
        final String language;
        final int preloadBytes;

        Policy(int shortSide, String language, int preloadBytes) {
            this.shortSide = shortSide;
            this.language = language == null ? "" : language.toLowerCase(Locale.ROOT).replace('_', '-');
            this.preloadBytes = preloadBytes;
        }
    }
}
