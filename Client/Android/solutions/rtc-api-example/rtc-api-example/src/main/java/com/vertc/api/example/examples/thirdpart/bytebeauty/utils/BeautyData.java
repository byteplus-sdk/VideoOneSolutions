package com.vertc.api.example.examples.thirdpart.bytebeauty.utils;

import androidx.annotation.NonNull;

import com.vertc.api.example.R;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectNode;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectSection;

import java.util.Arrays;
import java.util.List;

public class BeautyData {

    public static List<EffectNode> getEffectNodes(@NonNull EffectSection section) {
        switch (section) {
            case BEAUTY:
                return getBeautyNodes();
            case FILTER:
                return getFilterNodes();
            case STICKER:
                return getStickerNodes();
            case BACKGROUND:
                return getVirtualBackgroundNodes();
            default:
                throw new IllegalArgumentException("Unknown section:" + section);
        }
    }

    private static List<EffectNode> getBeautyNodes() {
        return Arrays.asList(
                EffectNode.beauty(R.string.label_beauty_whiten_title, "whiten", "beauty", true),
                EffectNode.beauty(R.string.label_beauty_smooth_title, "smooth", "beauty")
        );
    }

    private static List<EffectNode> getFilterNodes() {
        return Arrays.asList(
                EffectNode.filter(R.string.label_filter_0603_title, "Filter_06_03", true),
                EffectNode.filter(R.string.label_filter_37l5_title, "Filter_37_L5"),
                EffectNode.filter(R.string.label_filter_35l3_title, "Filter_35_L3"),
                EffectNode.filter(R.string.label_filter_308_title, "Filter_30_Po8")
        );

    }

    private static List<EffectNode> getStickerNodes() {
        return Arrays.asList(
                EffectNode.sticker(R.string.label_sticker_0_title, "huanlongshu"),
                EffectNode.sticker(R.string.label_sticker_1_title, "gongzhumianju"),
                EffectNode.sticker(R.string.label_sticker_2_title, "haoqilongbao"),
                EffectNode.sticker(R.string.label_sticker_3_title, "eldermakup"),
                EffectNode.sticker(R.string.label_sticker_4_title, "heimaoyanjing"),
                EffectNode.sticker(R.string.label_sticker_5_title, "huahua"),
                EffectNode.sticker(R.string.label_sticker_6_title, "huanletuchiluobo"),
                EffectNode.sticker(R.string.label_sticker_7_title, "jiamian")
        );
    }

    private static List<EffectNode> getVirtualBackgroundNodes() {
        return Arrays.asList(
                EffectNode.virtualBackground(R.string.label_virtual_color_title, "color"),
                EffectNode.virtualBackground(R.string.label_virtual_image_title, "image")
        );
    }
}
