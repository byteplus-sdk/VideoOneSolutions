// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.theater;

import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;

import java.util.List;

public interface IDramaTheaterClickListener {
    void onClick(DramaInfo info, int position, List<DramaInfo> infos);
}
