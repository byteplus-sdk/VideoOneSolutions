package com.vertcdemo.core.http.bean;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

public class RTCAppInfo implements Parcelable {
    public static final String KEY_APP_INFO = "key_app_info";

    @SerializedName("app_id")
    public final String appId;
    @SerializedName("bid")
    public final String bid;

    public boolean isInvalid() {
        return TextUtils.isEmpty(appId);
    }

    public RTCAppInfo(String appId, String bid) {
        this.appId = appId;
        this.bid = bid;
    }

    protected RTCAppInfo(Parcel in) {
        appId = in.readString();
        bid = in.readString();
    }

    public static final Creator<RTCAppInfo> CREATOR = new Creator<RTCAppInfo>() {
        @Override
        public RTCAppInfo createFromParcel(Parcel in) {
            return new RTCAppInfo(in);
        }

        @Override
        public RTCAppInfo[] newArray(int size) {
            return new RTCAppInfo[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeString(appId);
        dest.writeString(bid);
    }
}