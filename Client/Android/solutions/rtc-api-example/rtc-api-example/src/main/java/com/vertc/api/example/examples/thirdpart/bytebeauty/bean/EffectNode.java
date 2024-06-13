package com.vertc.api.example.examples.thirdpart.bytebeauty.bean;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;


public class EffectNode {

    public static EffectNode virtualBackground(@StringRes int title, @NonNull String key) {
        return new EffectNode(title, key, EffectType.virtualBackground);
    }

    public static EffectNode sticker(@StringRes int title, @NonNull String key) {
        return new EffectNode(title, key, EffectType.sticker);
    }

    public static EffectNode filter(@StringRes int title, String key, boolean selected) {
        return new EffectNode(title, key, EffectType.filter, selected);
    }

    public static EffectNode filter(@StringRes int title, String key) {
        return filter(title, key, false);
    }

    public static EffectNode beauty(@StringRes int title, String key, String subKey, boolean selected) {
        return new EffectNode(title, key, EffectType.beauty, subKey, selected);
    }

    public static EffectNode beauty(@StringRes int title, String key, String subkey) {
        return beauty(title, key, subkey, false);
    }

    @StringRes
    public final int title;
    public final String key;

    public final EffectType type;

    public final String subKey;

    public final boolean selected;

    public float value;

    private EffectNode(@StringRes int title, String key, EffectType type, String subKey, boolean selected) {
        this.title = title;
        this.key = key;
        this.type = type;
        this.subKey = subKey;
        this.selected = selected;
    }

    private EffectNode(@StringRes int title, String key, EffectType type, boolean selected) {
        this(title, key, type, null, selected);
    }

    private EffectNode(@StringRes int title, String key, EffectType type) {
        this(title, key, type, null, false);
    }

    public EffectNode copy(boolean selected) {
        EffectNode node = new EffectNode(this.title, this.key, this.type, this.subKey, selected);
        node.value = this.value;
        return node;
    }

    public EffectNode copy(boolean selected, float value) {
        EffectNode node = new EffectNode(this.title, this.key, this.type, this.subKey, selected);
        node.value = value;
        return node;
    }

    @NonNull
    @Override
    public String toString() {
        return "EffectNode{" +
                "title=" + title +
                ", key='" + key + '\'' +
                ", subKey='" + subKey + '\'' +
                ", type=" + type +
                ", value=" + value +
                ", selected=" + selected +
                '}';
    }
}
