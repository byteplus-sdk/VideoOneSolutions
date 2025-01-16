// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.remote.model.drama;

import com.google.gson.annotations.SerializedName;

import java.util.Collections;
import java.util.List;

public class DramaTheaterEntity {

    @SerializedName(value = "loop")
    public List<DramaInfo> loop;
    @SerializedName(value = "trending")
    public List<DramaInfo> trending;
    @SerializedName(value = "new")
    public List<DramaInfo> news;
    @SerializedName(value = "recommend")
    public List<DramaInfo> recommend;

    public List<DramaInfo> getInfos(DramaTheaterType type) {
        return switch (type) {
            case NEW -> (news == null ? Collections.<DramaInfo>emptyList() : news);
            case LOOP -> (loop == null ? Collections.<DramaInfo>emptyList() : loop);
            case TRENDING -> (trending == null ? Collections.<DramaInfo>emptyList() : trending);
            case RECOMMEND -> (recommend == null ? Collections.<DramaInfo>emptyList() : recommend);
        };
    }
}
