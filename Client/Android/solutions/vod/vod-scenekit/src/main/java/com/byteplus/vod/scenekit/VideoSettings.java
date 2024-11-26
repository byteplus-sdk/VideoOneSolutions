// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.cache.CacheLoader;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.player.ve.PlayerConfig;
import com.byteplus.playerkit.player.ve.VEPlayerStatic;
import com.byteplus.playerkit.utils.FileUtils;
import com.byteplus.vod.scenekit.annotation.CompleteAction;
import com.byteplus.vod.settingskit.CenteredToast;
import com.byteplus.vod.settingskit.Option;
import com.byteplus.vod.settingskit.Options;
import com.byteplus.vod.settingskit.OptionsDefault;
import com.byteplus.vod.settingskit.SettingItem;
import com.byteplus.vod.settingskit.Settings;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

public class VideoSettings {
    public static final String KEY = "AppSettings";

    public static final String CATEGORY_SHORT_VIDEO = "short-video";
    public static final String CATEGORY_FEED_VIDEO = "feed-video";
    public static final String CATEGORY_LONG_VIDEO = "long-video";

    public static final String CATEGORY_DETAIL_VIDEO = "category-video-details";

    public static final String CATEGORY_COMMON_VIDEO = "category-video-commons";
    public static final String CATEGORY_DEBUG = "category-debug";

    public static final String CATEGORY_NO_UI = "category-no-ui";

    public static final String SHORT_VIDEO_SCENE_ACCOUNT_ID = "short_video_scene_account_id";
    public static final String SHORT_VIDEO_ENABLE_STRATEGY = "short_video_enable_strategy";
    public static final String SHORT_VIDEO_ENABLE_IMAGE_COVER = "short_video_enable_image_cover";
    public static final String SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION = "short_video_playback_complete_action";

    public static final String FEED_VIDEO_ENABLE_PRELOAD = "feed_video_enable_preload";
    public static final String FEED_VIDEO_SCENE_ACCOUNT_ID = "feed_video_scene_account_id";

    public static final String LONG_VIDEO_SCENE_ACCOUNT_ID = "long_video_scene_account_id";

    public static final String DETAIL_VIDEO_SCENE_FRAGMENT_OR_ACTIVITY = "detail_video_scene_fragment_or_activity";

    public static final String DEBUG_ENABLE_LOG_LAYER = "debug_enable_log_layer";
    public static final String DEBUG_ENABLE_DEBUG_TOOL = "debug_enable_debug_tool";

    public static final String COMMON_CODEC_STRATEGY = "common_codec_strategy";
    public static final String COMMON_HARDWARE_DECODE = "common_hardware_decode";
    public static final String COMMON_SUPER_RESOLUTION = "common_super_resolution";
    public static final String COMMON_SOURCE_TYPE = "common_source_type";
    public static final String COMMON_SOURCE_ENCODE_TYPE_H265 = "common_source_encode_type_h265";
    public static final String COMMON_SOURCE_VIDEO_FORMAT_TYPE = "common_source_video_format_type";
    public static final String COMMON_IS_MINIPLAYER_ON = "common_is_miniplayer_on";

    public static final String COMMON_SHOW_FULL_SCREEN_TIPS = "show_full_screen_tips";


    private static final String ACTION_INPUT_MEDIA_SOURCE = "com.byteplus.vod.scenekit.action.INPUT_MEDIA_SOURCE";

    private static Options sOptions;

    @SuppressLint("StaticFieldLeak")
    private static Context sContext;

    public static class DecoderType {
        public static final int AUTO = Player.DECODER_TYPE_UNKNOWN;
        public static final int HARDWARE = Player.DECODER_TYPE_HARDWARE;
        public static final int SOFTWARE = Player.DECODER_TYPE_SOFTWARE;
    }

    public static class CodecStrategy {
        public static final int CODEC_STRATEGY_DISABLE = PlayerConfig.CODEC_STRATEGY_DISABLE;
        public static final int CODEC_STRATEGY_COST_SAVING_FIRST = PlayerConfig.CODEC_STRATEGY_COST_SAVING_FIRST;
        public static final int CODEC_STRATEGY_HARDWARE_DECODE_FIRST = PlayerConfig.CODEC_STRATEGY_HARDWARE_DECODE_FIRST;
    }

    public static class FormatType {
        public static final int FORMAT_TYPE_MP4 = Track.FORMAT_MP4;
        public static final int FORMAT_TYPE_DASH = Track.FORMAT_DASH;
        public static final int FORMAT_TYPE_HLS = Track.FORMAT_HLS;
    }

    public static class SourceType {
        public static final int SOURCE_TYPE_URL = MediaSource.SOURCE_TYPE_URL;
        public static final int SOURCE_TYPE_VID = MediaSource.SOURCE_TYPE_ID;
        public static final int SOURCE_TYPE_MODEL = MediaSource.SOURCE_TYPE_MODEL;
    }

    /**
     * @see R.bool#vevod_settings_filter_enabled
     */
    private static final List<String> FILTER_OUT_ABLE_KEYS = Collections.emptyList();

    public static void init(Context context) {
        sContext = context;
        List<SettingItem> settings = createSettings();
        sOptions = new OptionsDefault(context, createOptions(settings));
        if (context.getResources().getBoolean(R.bool.vevod_settings_filter_enabled)) {
            Iterator<SettingItem> iterator = settings.iterator();
            while (iterator.hasNext()) { // remove unsupported settings
                SettingItem item = iterator.next();
                if (item.option == null) {
                    continue;
                }
                if (CATEGORY_NO_UI.equals(item.category) ||
                        FILTER_OUT_ABLE_KEYS.contains(item.option.key)) {
                    iterator.remove();
                }
            }
        }
        Settings.put(KEY, settings);
    }

    private static List<Option> createOptions(List<SettingItem> settings) {
        List<Option> options = new ArrayList<>();
        for (SettingItem item : settings) {
            if (item.type == SettingItem.TYPE_OPTION) {
                options.add(item.option);
            }
        }
        appendOptions(options);
        return options;
    }

    private static void appendOptions(@NonNull List<Option> options) {
        options.add(new Option(
                Option.TYPE_RATIO_BUTTON,
                CATEGORY_NO_UI,
                COMMON_SHOW_FULL_SCREEN_TIPS,
                ResourcesCompat.ID_NULL,
                Boolean.class,
                Boolean.TRUE));
        options.add(new Option(
                Option.TYPE_RATIO_BUTTON,
                CATEGORY_NO_UI,
                COMMON_IS_MINIPLAYER_ON,
                ResourcesCompat.ID_NULL,
                Boolean.class,
                Boolean.FALSE));
    }

    @Nullable
    public static Option option(String key) {
        if (sOptions == null) {
            return null;
        }
        return sOptions.option(key);
    }

    public static int intValue(String key) {
        return option(key).intValue();
    }

    public static boolean booleanValue(String key) {
        return option(key).booleanValue();
    }

    public static long longValue(String key) {
        return option(key).longValue();
    }

    public static float floatValue(String key) {
        return option(key).floatValue();
    }

    @Nullable
    public static String stringValue(String key) {
        return option(key).stringValue();
    }

    private static List<SettingItem> createSettings() {
        List<SettingItem> settings = new ArrayList<>();
        createDebugSettings(settings);
        createShortVideoSettings(settings);
        createFeedVideoSettings(settings);
        createLongVideoSettings(settings);
        createDetailVideoSettings(settings);
        createCommonSettings(settings);
        return settings;
    }

    private static void createDebugSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_DEBUG, R.string.vevod_option_category_debug));
        settings.add(SettingItem.createOptionItem(CATEGORY_DEBUG,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_DEBUG,
                        DEBUG_ENABLE_LOG_LAYER,
                        R.string.vevod_option_debug_enable_log_layer,
                        Boolean.class,
                        Boolean.FALSE)));
        settings.add(SettingItem.createOptionItem(CATEGORY_DEBUG,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_DEBUG,
                        DEBUG_ENABLE_DEBUG_TOOL,
                        R.string.vevod_option_debug_enable_debug_tool,
                        Boolean.class,
                        Boolean.FALSE)));

        settings.add(SettingItem.createActionItem(
                CATEGORY_DEBUG,
                R.string.vevod_option_debug_input_media_source,
                (eventType, context, settingItem, holder) -> {
                    try {
                        Intent intent = new Intent(ACTION_INPUT_MEDIA_SOURCE);
                        intent.setPackage(context.getPackageName());
                        context.startActivity(intent);
                    } catch (Exception e) {
                        Toast.makeText(context, "Not Implemented", Toast.LENGTH_SHORT).show();
                    }
                }
        ));
    }

    private static void createShortVideoSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_SHORT_VIDEO, R.string.vevod_option_category_short_video));

        settings.add(SettingItem.createOptionItem(CATEGORY_SHORT_VIDEO,
                new Option(
                        Option.TYPE_EDITABLE_TEXT,
                        CATEGORY_SHORT_VIDEO,
                        SHORT_VIDEO_SCENE_ACCOUNT_ID,
                        R.string.vevod_option_short_video_scene_account_id,
                        String.class,
                        "short-video")));

        settings.add(SettingItem.createOptionItem(CATEGORY_SHORT_VIDEO,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_SHORT_VIDEO,
                        SHORT_VIDEO_ENABLE_STRATEGY,
                        R.string.vevod_option_short_video_enable_strategy,
                        Boolean.class,
                        Boolean.TRUE)));

        settings.add(SettingItem.createOptionItem(CATEGORY_SHORT_VIDEO,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_SHORT_VIDEO,
                        SHORT_VIDEO_ENABLE_IMAGE_COVER,
                        R.string.vevod_option_short_video_enable_image_cover,
                        Boolean.class,
                        Boolean.TRUE)));

        settings.add(SettingItem.createOptionItem(CATEGORY_SHORT_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_SHORT_VIDEO,
                        SHORT_VIDEO_PLAYBACK_COMPLETE_ACTION,
                        R.string.vevod_option_short_video_playback_complete_action,
                        Integer.class,
                        CompleteAction.LOOP,
                        Arrays.asList(CompleteAction.LOOP, CompleteAction.NEXT)), new SettingItem.ValueMapper() {
                    @Override
                    public String toString(Object value) {
                        final int action = (int) value;
                        switch (action) {
                            case 0:
                                return getString(R.string.vevod_option_short_video_playback_complete_action_loop);
                            case 1:
                                return getString(R.string.vevod_option_short_video_playback_complete_action_next);
                        }
                        return null;
                    }
                }));
    }

    private static void createFeedVideoSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_FEED_VIDEO, R.string.vevod_option_category_feed_video));
        settings.add(SettingItem.createOptionItem(CATEGORY_SHORT_VIDEO,
                new Option(
                        Option.TYPE_EDITABLE_TEXT,
                        CATEGORY_FEED_VIDEO,
                        FEED_VIDEO_SCENE_ACCOUNT_ID,
                        R.string.vevod_option_feed_video_scene_account_id,
                        String.class,
                        "feedvideo")));
        settings.add(SettingItem.createOptionItem(CATEGORY_FEED_VIDEO,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_FEED_VIDEO,
                        FEED_VIDEO_ENABLE_PRELOAD,
                        R.string.vevod_option_feed_video_enable_preload,
                        Boolean.class,
                        Boolean.TRUE)));
    }

    private static void createLongVideoSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_LONG_VIDEO, R.string.vevod_option_category_long_video));
        settings.add(SettingItem.createOptionItem(CATEGORY_LONG_VIDEO,
                new Option(
                        Option.TYPE_EDITABLE_TEXT,
                        CATEGORY_LONG_VIDEO,
                        LONG_VIDEO_SCENE_ACCOUNT_ID,
                        R.string.vevod_option_long_video_scene_account_id,
                        String.class,
                        "long-video")));
    }

    private static void createDetailVideoSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_DETAIL_VIDEO, R.string.vevod_option_category_video_details));
        settings.add(SettingItem.createOptionItem(CATEGORY_DETAIL_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_DETAIL_VIDEO,
                        DETAIL_VIDEO_SCENE_FRAGMENT_OR_ACTIVITY,
                        R.string.vevod_option_detail_video_scene_fragment_or_activity,
                        String.class,
                        "Fragment",
                        Arrays.asList("Fragment", "Activity"))));
    }

    private static void createCommonSettings(List<SettingItem> settings) {
        settings.add(SettingItem.createCategoryItem(CATEGORY_COMMON_VIDEO, R.string.vevod_option_category_commons));

        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_CODEC_STRATEGY,
                        R.string.vevod_option_common_codec_strategy,
                        Integer.class,
                        CodecStrategy.CODEC_STRATEGY_DISABLE,
                        Arrays.asList(CodecStrategy.CODEC_STRATEGY_DISABLE,
                                CodecStrategy.CODEC_STRATEGY_COST_SAVING_FIRST,
                                CodecStrategy.CODEC_STRATEGY_HARDWARE_DECODE_FIRST)),
                new SettingItem.ValueMapper() {
                    @Override
                    public String toString(Object value) {
                        switch ((Integer) value) {
                            case CodecStrategy.CODEC_STRATEGY_DISABLE:
                                return getString(R.string.vevod_option_common_codec_strategy_disable);
                            case CodecStrategy.CODEC_STRATEGY_COST_SAVING_FIRST:
                                return getString(R.string.vevod_option_common_codec_strategy_cost_saving_first);
                            case CodecStrategy.CODEC_STRATEGY_HARDWARE_DECODE_FIRST:
                                return getString(R.string.vevod_option_common_codec_strategy_hardware_decode_first);
                        }
                        return null;
                    }
                }));

        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_HARDWARE_DECODE,
                        R.string.vevod_option_common_hardware_decode,
                        Integer.class,
                        DecoderType.AUTO,
                        Arrays.asList(DecoderType.AUTO, DecoderType.HARDWARE, DecoderType.SOFTWARE)),
                new SettingItem.ValueMapper() {
                    @Override
                    public String toString(Object value) {
                        switch ((Integer) value) {
                            case DecoderType.AUTO:
                                return getString(R.string.vevod_option_common_hardware_decode_auto);
                            case DecoderType.HARDWARE:
                                return getString(R.string.vevod_option_common_hardware_decode_hardware);
                            case DecoderType.SOFTWARE:
                                return getString(R.string.vevod_option_common_hardware_decode_software);
                        }
                        return null;
                    }
                }));

        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_SUPER_RESOLUTION,
                        R.string.vevod_option_common_super_resolution,
                        Boolean.class,
                        Boolean.FALSE)));

        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_RATIO_BUTTON,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_SOURCE_ENCODE_TYPE_H265,
                        R.string.vevod_option_common_source_encode_type_bytevc1,
                        Boolean.class,
                        Boolean.TRUE)));


        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_SOURCE_TYPE,
                        R.string.vevod_option_common_source_type,
                        Integer.class,
                        SourceType.SOURCE_TYPE_VID,
                        Arrays.asList(SourceType.SOURCE_TYPE_VID, SourceType.SOURCE_TYPE_URL, SourceType.SOURCE_TYPE_MODEL)),
                new SettingItem.ValueMapper() {
                    @Override
                    public String toString(Object value) {
                        switch ((Integer) value) {
                            case SourceType.SOURCE_TYPE_VID:
                                return getString(R.string.vevod_option_common_source_type_vid);
                            case SourceType.SOURCE_TYPE_URL:
                                return getString(R.string.vevod_option_common_source_type_url);
                            case SourceType.SOURCE_TYPE_MODEL:
                                return getString(R.string.vevod_option_common_source_type_model);
                        }
                        return null;
                    }
                }));


        settings.add(SettingItem.createOptionItem(CATEGORY_COMMON_VIDEO,
                new Option(
                        Option.TYPE_SELECTABLE_ITEMS,
                        CATEGORY_COMMON_VIDEO,
                        COMMON_SOURCE_VIDEO_FORMAT_TYPE,
                        R.string.vevod_option_common_source_video_format_type,
                        Integer.class,
                        FormatType.FORMAT_TYPE_MP4,
                        Arrays.asList(FormatType.FORMAT_TYPE_MP4, FormatType.FORMAT_TYPE_DASH, FormatType.FORMAT_TYPE_HLS)),
                new SettingItem.ValueMapper() {
                    @Override
                    public String toString(Object value) {
                        switch ((Integer) value) {
                            case FormatType.FORMAT_TYPE_MP4:
                                return getString(R.string.vevod_option_common_source_video_format_type_mp4);
                            case FormatType.FORMAT_TYPE_DASH:
                                return getString(R.string.vevod_option_common_source_video_format_type_dash);
                            case FormatType.FORMAT_TYPE_HLS:
                                return getString(R.string.vevod_option_common_source_video_format_type_hls);
                        }
                        return null;
                    }
                }));

        settings.add(SettingItem.createCopyableTextItem(CATEGORY_COMMON_VIDEO,
                R.string.vevod_option_common_device_id,
                new SettingItem.Getter(VEPlayerStatic::getDeviceId)
        ));

        settings.add(SettingItem.createCopyableTextItem(CATEGORY_COMMON_VIDEO,
                R.string.vevod_option_common_ttsdk_version,
                new SettingItem.Getter(VEPlayerStatic::getSDKVersion)
        ));

        final CleanCacheHolder holder = new CleanCacheHolder();
        settings.add(SettingItem.createClickableItem(CATEGORY_COMMON_VIDEO,
                R.string.vevod_option_common_clean_cache, new SettingItem.Getter(holder), holder));

    }

    private static class CleanCacheHolder implements SettingItem.Getter.AsyncGetter, SettingItem.OnEventListener {

        private boolean mIsGetting = false;
        private boolean mIsCleaning = false;

        @Override
        public void get(SettingItem.Setter setter) {
            if (mIsGetting) return;
            mIsGetting = true;
            new Thread(() -> {
                long videoFileSize = FileUtils.getFileSize(CacheLoader.Default.get().getCacheDir());
                long imageFileSize = FileUtils.getFileSize(Glide.getPhotoCacheDir(sContext));
                long size = imageFileSize + videoFileSize;
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        setter.set(FileUtils.formatSize(size));
                        mIsGetting = false;
                    }
                });
            }).start();
        }

        @Override
        public void onEvent(int eventType, Context context, SettingItem settingItem, RecyclerView.ViewHolder holder) {
            if (eventType == SettingItem.OnEventListener.EVENT_TYPE_CLICK) {
                if (mIsCleaning) return;
                mIsCleaning = true;

                CenteredToast.show(context, R.string.vevod_cleaning_cache);
                new Thread(() -> {
                    CacheLoader.Default.get().clearCache();
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            mIsGetting = false;
                            mIsCleaning = false;
                            CenteredToast.show(context, R.string.vevod_cache_cleaned);
                            RecyclerView.Adapter<?> adapter = holder.getBindingAdapter();
                            if (adapter != null) {
                                adapter.notifyItemChanged(holder.getAbsoluteAdapterPosition());
                            }
                        }
                    });
                }).start();
            }
        }
    }

    private static String getString(@StringRes int id) {
        return sContext.getString(id);
    }

}

