// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
import com.vertcdemo.solution.ktv.core.rts.annotation.NeedApply;

import org.json.JSONException;
import org.json.JSONObject;

public class RoomInfo implements Parcelable {
    private static final String TAG = "RoomInfo";

    @SerializedName("app_id")
    public String appId;
    @SerializedName("room_id")
    public String roomId;
    @SerializedName("room_name")
    public String roomName;
    @SerializedName("host_user_id")
    public String hostUserId;
    @SerializedName("host_user_name")
    public String hostUserName;
    @SerializedName("status")
    public int status;
    @SerializedName("enable_audience_interact_apply")
    @NeedApply
    public int enableAudienceInteractApply;
    @SerializedName("start_time")
    public long startTime;
    @SerializedName("end_time")
    public long endTime;
    @SerializedName("audience_count")
    public int audienceCount;
    @SerializedName("ext")
    public String extraInfo;

    public boolean needApply() {
        return enableAudienceInteractApply == NeedApply.ON;
    }

    public RoomInfo() {

    }

    protected RoomInfo(Parcel in) {
        appId = in.readString();
        roomId = in.readString();
        roomName = in.readString();
        hostUserId = in.readString();
        hostUserName = in.readString();
        status = in.readInt();
        enableAudienceInteractApply = in.readInt();
        startTime = in.readLong();
        endTime = in.readLong();
        audienceCount = in.readInt();
        extraInfo = in.readString();
    }

    public static final Creator<RoomInfo> CREATOR = new Creator<RoomInfo>() {
        @Override
        public RoomInfo createFromParcel(Parcel in) {
            return new RoomInfo(in);
        }

        @Override
        public RoomInfo[] newArray(int size) {
            return new RoomInfo[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeString(appId);
        dest.writeString(roomId);
        dest.writeString(roomName);
        dest.writeString(hostUserId);
        dest.writeString(hostUserName);
        dest.writeInt(status);
        dest.writeInt(enableAudienceInteractApply);
        dest.writeLong(startTime);
        dest.writeLong(endTime);
        dest.writeInt(audienceCount);
        dest.writeString(extraInfo);
    }

    @Override
    @NonNull
    public String toString() {
        return "VCRoomInfo{" +
                "appId='" + appId + '\'' +
                ", requireRoomId='" + roomId + '\'' +
                ", roomName='" + roomName + '\'' +
                ", hostUserId='" + hostUserId + '\'' +
                ", hostUserName='" + hostUserName + '\'' +
                ", status=" + status +
                ", enableAudienceInteractApply=" + enableAudienceInteractApply +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", audienceCount=" + audienceCount +
                ", extraInfo='" + extraInfo + '\'' +
                '}';
    }

    @Nullable
    public String getBackgroundKey() {
        if (extraInfo == null) {
            return null;
        }
        try {
            JSONObject json = new JSONObject(extraInfo);
            return json.getString("background_image_name");
        } catch (JSONException e) {
            Log.d(TAG, "getBackgroundKey: ", e);
        }
        return null;
    }
}
