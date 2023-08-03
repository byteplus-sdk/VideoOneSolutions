// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.bean;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

public class LiveSummary implements Parcelable {
    @SerializedName("likes")
    public int likes;
    @SerializedName("gifts")
    public int gifts;
    @SerializedName("viewers")
    public int viewers;

    public LiveSummary() {

    }

    // region Parcelable implementation
    protected LiveSummary(Parcel in) {
        likes = in.readInt();
        gifts = in.readInt();
        viewers = in.readInt();
    }

    public static final Creator<LiveSummary> CREATOR = new Creator<LiveSummary>() {
        @Override
        public LiveSummary createFromParcel(Parcel in) {
            return new LiveSummary(in);
        }

        @Override
        public LiveSummary[] newArray(int size) {
            return new LiveSummary[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeInt(likes);
        dest.writeInt(gifts);
        dest.writeInt(viewers);
    }
    // endregion
}
