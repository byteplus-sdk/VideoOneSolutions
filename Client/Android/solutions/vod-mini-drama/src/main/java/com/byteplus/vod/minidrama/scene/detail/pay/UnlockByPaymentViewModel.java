// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class UnlockByPaymentViewModel extends ViewModel {
    public final MutableLiveData<SKU> sku = new MutableLiveData<>(SKU.COUNT);
}
