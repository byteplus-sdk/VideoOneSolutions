package com.byteplus.vodcommon.data.remote.api2.model;

import com.google.gson.annotations.SerializedName;

public class GetPlayListRequest {

    @SerializedName("format")
    public Integer format;
    @SerializedName("codec")
    public Integer codec;
    @SerializedName("fileType")
    public String fileType;

    public GetPlayListRequest(Integer format, Integer codec, String fileType) {
        this.format = format;
        this.codec = codec;
        this.fileType = fileType;
    }
}
