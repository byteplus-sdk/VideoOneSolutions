// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload;

import com.ss.bduploader.BDVideoInfo;
import com.ss.bduploader.BDVideoUploaderListener;

public class BDVideoUploaderAdapter implements BDVideoUploaderListener {
    @Override
    public void onNotify(int what, long parameter, BDVideoInfo info) {

    }

    @Override
    public void onLog(int what, int code, String info) {

    }

    @Override
    public void onUploadVideoStage(int stage,long timestamp) {

    }

    @Override
    public int videoUploadCheckNetState(int errorCode, int tryCount) {
        return 0;
    }

    @Override
    public String getStringFromExtern(int key) {
        return null;
    }
}
