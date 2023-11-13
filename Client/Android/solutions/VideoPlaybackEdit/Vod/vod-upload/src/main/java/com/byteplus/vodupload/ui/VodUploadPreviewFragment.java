// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.ui;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.byteplus.vodupload.IUploadListener;
import com.byteplus.vodupload.R;
import com.byteplus.vodupload.UploadApi;
import com.byteplus.vodupload.widget.CustomToast;
import com.byteplus.vodupload.widget.ProgressDialog;
import com.ss.android.vesdk.VEUtils;
import com.ss.bduploader.BDVideoUploader;

public class VodUploadPreviewFragment extends Fragment {

    public static final String EXTRA_MEDIA_PATH = "extra_media_path";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_vod_upload_preview, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ImageView iv = view.findViewById(R.id.iv_upload_preview_img);
        String videoPath = getArguments().getString(EXTRA_MEDIA_PATH, "");
        VEUtils.getVideoFrames(videoPath, new int[]{0}, (frame, width, height, ptsMs) -> {
            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            bitmap.copyPixelsFromBuffer(frame.position(0));
            iv.setImageBitmap(bitmap);
            return false; // false because we don't need next frame
        });

        view.findViewById(R.id.tv_upload_back_to_home).setOnClickListener(v -> getActivity().finish());
        view.findViewById(R.id.tv_upload_btn).setOnClickListener(v -> doUpload(videoPath));
    }

    private void doUpload(String videoPath) {
        ProgressDialog dialog = new ProgressDialog(getActivity());
        dialog.setCancelable(false);
        dialog.setProgressText(String.format(getResources().getString(R.string.vod_upload_progress_txt), 0));
        dialog.show();
        UploadApi.getInstance().startUpload(videoPath, ".mp4",
                "videoone/", 600, new IUploadListener() {
            @Override
            public void onUploadProgress(int progress) {
                dialog.setProgressText(String.format(getResources().getString(R.string.vod_upload_progress_txt), progress));
            }

            @Override
            public void onUploadSuccess() {
                dialog.dismiss();
                CustomToast.show(getActivity(), R.drawable.vod_uploaded_successfully, R.string.vod_uploaded_successfully);
                getActivity().finish();
            }

            @Override
            public void onError(String errMsg) {
                dialog.dismiss();
                CustomToast.show(getActivity(), R.drawable.vod_uploaded_failed, R.string.vod_uploaded_failed);
            }
        });

    }
}
