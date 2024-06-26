// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.core;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.util.Objects;

public class ChorusInfo {
    public static final ChorusInfo empty = new ChorusInfo("", null, null);

    public final String leaderSingerUid;
    public final String supportingSingerUid;
    public final String myUid;

    public ChorusInfo(@NonNull String myUid, String leaderSingerUid, String supportingSingerUid) {
        this.myUid = Objects.requireNonNull(myUid);
        this.leaderSingerUid = leaderSingerUid;
        this.supportingSingerUid = supportingSingerUid;
    }

    public boolean isLeaderSinger() {
        return myUid.equals(leaderSingerUid);
    }

    public boolean isSupportingSinger() {
        return myUid.equals(supportingSingerUid);
    }

    public boolean isSinger() {
        return isSinger(myUid);
    }

    public boolean isSinger(@NonNull String uid) {
        return TextUtils.equals(uid, leaderSingerUid) || TextUtils.equals(uid, supportingSingerUid);
    }
}
