// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vodcommon.data.remote.api2;

import static com.byteplus.vodcommon.data.remote.api2.Params.Format.DASHFormat;
import static com.byteplus.vodcommon.data.remote.api2.Params.Format.HLSFormat;
import static com.byteplus.vodcommon.data.remote.api2.Params.Format.MP4Format;

import com.byteplus.vod.scenekit.VideoSettings;

public class Params {

    public static class Value {

        public static Integer format() {
            final int format = VideoSettings.intValue(VideoSettings.COMMON_SOURCE_VIDEO_FORMAT_TYPE);
            switch (format) {
                case VideoSettings.FormatType.FORMAT_TYPE_MP4:
                    return MP4Format;
                case VideoSettings.FormatType.FORMAT_TYPE_DASH:
                    return DASHFormat;
                case VideoSettings.FormatType.FORMAT_TYPE_HLS:
                    return HLSFormat;
            }
            return MP4Format;
        }

        public static Integer codec() {
            boolean h265 = VideoSettings.booleanValue(VideoSettings.COMMON_SOURCE_ENCODE_TYPE_H265);
            return h265 ? Codec.MH265Codec : Codec.H264Codec;
        }
    }

    public static class Format {
        public static final int UndefinedFormat = 0;
        public static final int MP4Format = 1;
        public static final int M4AFormat = 2;
        public static final int M3U8Format = 4;
        public static final int GIFFormat = 5;
        public static final int DASHFormat = 6;
        public static final int OGGFormat = 7;
        public static final int FMP4Format = 8;
        public static final int HLSFormat = 9;
    }

    public static class Codec {
        public static final int H264Codec = 0;
        public static final int MH265Codec = 1;// (h264+1)
        public static final int OH265Codec = 2; // (h264+1)_hvc1
        public static final int ALLCodec = 3;
        public static final int OPUSCodec = 4;
        public static final int AACCodec = 5;
        public static final int MP3Codec = 6;
        public static final int H265Codec = 7;
        public static final int AllWithH265Codec = 8; // h264、H265
    }
}
