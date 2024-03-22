// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.bean;

public class MusicDownloadInfo {
    /***未下载***/
    public static final int STATUS_UN_DOWNLOAD = 0;
    /***下载中***/
    public static final int STATUS_DOWNLOADING = 1;
    /***下载完成***/
    public static final int STATUS_DOWNLOADED = 2;
    public String musicId;
    public String musicName;
    public String mp3Url;
    public String lrcUrl;

    public long mp3DownloadId;
    public String mp3FileUri;
    public int mp3DownloadStatus = STATUS_UN_DOWNLOAD;
    public long lrcDownloadId;
    public String lrcFileUri;
    public int lrcDownloadStatus = STATUS_UN_DOWNLOAD;

    public boolean hasDownloaded() {
        return mp3DownloadStatus == STATUS_DOWNLOADED && lrcDownloadStatus == STATUS_DOWNLOADED;
    }

    public boolean isDownloading() {
        return mp3DownloadStatus == STATUS_DOWNLOADING || lrcDownloadStatus == STATUS_DOWNLOADING;
    }

    public boolean isLrcUnDownload() {
        return lrcDownloadStatus == STATUS_UN_DOWNLOAD || lrcDownloadStatus == STATUS_DOWNLOAD_FAILED;
    }

    public boolean isMp3UnDownload() {
        return mp3DownloadStatus == STATUS_UN_DOWNLOAD || mp3DownloadStatus == STATUS_DOWNLOAD_FAILED;
    }

    /***下载失败***/
    public static final int STATUS_DOWNLOAD_FAILED = 3;
    public int errCode;
    public String errMsg;
}
