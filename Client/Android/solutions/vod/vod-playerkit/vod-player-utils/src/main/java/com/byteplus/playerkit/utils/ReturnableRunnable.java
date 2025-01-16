// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;

public interface ReturnableRunnable<Result, Param> {

    Result run(Param p);
}
