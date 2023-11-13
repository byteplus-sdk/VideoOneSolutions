// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload;

public interface IUploadListener {
    void onUploadProgress(int progress);
    void onUploadSuccess();
    void onError(String errMsg);
}
