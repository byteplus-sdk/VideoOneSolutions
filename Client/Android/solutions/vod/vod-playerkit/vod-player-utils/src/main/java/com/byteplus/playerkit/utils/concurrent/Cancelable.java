// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils.concurrent;


public interface Cancelable {

    void cancel(boolean notify, boolean interrupt, String reason);

    boolean isCanceled();
}
