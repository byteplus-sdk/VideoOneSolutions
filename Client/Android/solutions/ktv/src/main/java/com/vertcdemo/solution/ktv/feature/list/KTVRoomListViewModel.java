// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.http.KTVService;
import com.vertcdemo.solution.ktv.http.response.GetRoomListResponse;
import com.vertcdemo.ui.CenteredToast;

import java.util.List;

public class KTVRoomListViewModel extends ViewModel {
    public final MutableLiveData<List<RoomInfo>> rooms = new MutableLiveData<>();

    public void requestRoomList() {
        KTVService service = KTVService.get();
        service.clearUser(() -> {
            service.getRoomList(new Callback<GetRoomListResponse>() {
                @Override
                public void onResponse(GetRoomListResponse response) {
                    rooms.postValue(GetRoomListResponse.rooms(response));
                }

                @Override
                public void onFailure(HttpException e) {
                    CenteredToast.show(ErrorCodes.prettyMessage(e));
                }
            });
        });
    }
}
