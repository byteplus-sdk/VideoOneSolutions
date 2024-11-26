// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import android.content.Context;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.common.AppExecutors;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.utils.LicenseChecker;
import com.vertcdemo.core.utils.LicenseResult;
import com.vertcdemo.solution.interactivelive.BuildConfig;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.GetRoomListResponse;
import com.vertcdemo.ui.CenteredToast;

import java.util.List;

public class LiveRoomListViewModel extends ViewModel {

    public final MutableLiveData<List<LiveRoomInfo>> rooms = new MutableLiveData<>();

    public final MutableLiveData<LicenseResult> licenseResult = new MutableLiveData<>(LicenseResult.empty);

    public void requestRoomList() {
        LiveService service = LiveService.get();
        service.clearUser(() -> service.getRoomList(new Callback<GetRoomListResponse>() {
            @Override
            public void onResponse(GetRoomListResponse response) {
                rooms.postValue(GetRoomListResponse.rooms(response));
            }

            @Override
            public void onFailure(HttpException e) {
                CenteredToast.show(ErrorTool.getErrorMessage(e));
            }
        }));
    }

    public void checkLicense(Context context) {
        AppExecutors.diskIO().execute(() -> {
            String licenseUri = BuildConfig.LIVE_TTSDK_LICENSE_URI;
            LicenseResult result = LicenseChecker.check(context, licenseUri);
            licenseResult.postValue(result);
        });
    }
}
