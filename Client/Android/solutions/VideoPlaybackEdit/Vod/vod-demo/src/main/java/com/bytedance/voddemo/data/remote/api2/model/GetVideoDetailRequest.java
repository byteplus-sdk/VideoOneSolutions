// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.bytedance.voddemo.data.remote.api2.model;


public class GetVideoDetailRequest {
    private final String vid;
    private final Integer format;
    private final Integer codec;
    private final Integer definition;
    private final String fileType;
    private final Boolean needOriginal;
    private final Boolean needBarrageMask;
    private final Integer cdnType;

    public GetVideoDetailRequest(
            final String vid,
            final Integer format,
            final Integer codec,
            final Integer definition,
            final String fileType,
            final Boolean needOriginal,
            final Boolean needBarrageMask,
            final Integer cdnType) {
        this.vid = vid;
        this.format = format;
        this.codec = codec;
        this.definition = definition;
        this.fileType = fileType;
        this.needOriginal = needOriginal;
        this.needBarrageMask = needBarrageMask;
        this.cdnType = cdnType;
    }
}
