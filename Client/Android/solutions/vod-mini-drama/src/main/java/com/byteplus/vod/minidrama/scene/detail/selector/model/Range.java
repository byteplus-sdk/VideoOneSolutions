// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.selector.model;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

/**
 * range of integers. [a, b] all must be positive, zero is not included.
 */
public class Range implements Parcelable {
    public final int from;
    public final int to;

    public Range(int from, int to) {
        this.from = from;
        this.to = to;
    }

    protected Range(Parcel in) {
        from = in.readInt();
        to = in.readInt();
    }

    public static final Creator<Range> CREATOR = new Creator<Range>() {
        @Override
        public Range createFromParcel(Parcel in) {
            return new Range(in);
        }

        @Override
        public Range[] newArray(int size) {
            return new Range[size];
        }
    };

    @NonNull
    @Override
    public String toString() {
        return "[" + from + ", " + to + "]";
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeInt(from);
        dest.writeInt(to);
    }

    public static final Range ZERO = new Range(0, 0);

    public boolean contains(int index) {
        if (index == 0) {
            return false;
        }
        return from <= index && index <= to;
    }
}
