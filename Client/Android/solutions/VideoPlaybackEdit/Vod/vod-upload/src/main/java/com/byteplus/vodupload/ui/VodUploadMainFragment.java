// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodupload.ui;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.byteplus.vodupload.R;


public class VodUploadMainFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_vod_upload_main, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.vod_upload_close).setOnClickListener(v -> getActivity().finish());
        view.findViewById(R.id.vod_upload_camera).setOnClickListener(v -> new CKHomeDelegate(getActivity()).startRecord());
        view.findViewById(R.id.vod_upload_album).setOnClickListener(v -> new CKHomeDelegate(getActivity()).startEditor());
    }
}
