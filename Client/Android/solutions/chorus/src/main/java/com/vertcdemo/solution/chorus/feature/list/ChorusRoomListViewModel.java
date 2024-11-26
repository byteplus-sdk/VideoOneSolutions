// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.list;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.core.ErrorCodes;
import com.vertcdemo.solution.chorus.http.ChorusService;
import com.vertcdemo.solution.chorus.http.response.GetRoomListResponse;
import com.vertcdemo.ui.CenteredToast;

import java.util.List;

public class ChorusRoomListViewModel extends ViewModel {
    public final MutableLiveData<List<RoomInfo>> rooms = new MutableLiveData<>();

    public void requestRoomList() {
        ChorusService service = ChorusService.get();
        service.clearUser(() -> service.getRoomList(new Callback<GetRoomListResponse>() {
            @Override
            public void onResponse(@Nullable GetRoomListResponse response) {
                rooms.postValue(GetRoomListResponse.rooms(response));
            }

            @Override
            public void onFailure(HttpException e) {
                CenteredToast.show(ErrorCodes.prettyMessage(e));
            }
        }));
    }
}