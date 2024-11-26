// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils;

import static com.vertcdemo.core.net.HttpException.ERROR_CODE_TOKEN_EMPTY;
import static com.vertcdemo.core.net.HttpException.ERROR_CODE_TOKEN_EXPIRED;

import androidx.annotation.NonNull;

import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.rtc.toolkit.R;

public class ErrorTool {

    public static String getErrorMessage(@NonNull HttpException e) {
        return getErrorMessage(e.getCode(), e.getMessage());
    }

    public static String getErrorMessage(int code, String message) {
        switch (code) {
            case -1011:
                return getString(R.string.network_message_1011);
            case -101:
                return getString(R.string.network_message_101);
            case -1:
                return getString(R.string.network_message_unknown);
            case 200:
                return getString(R.string.network_message_200);
            case 400:
                return getString(R.string.network_message_400);
            case 402:
                return getString(R.string.network_message_402);
            case 404:
                return getString(R.string.network_message_404);
            case 406:
                return getString(R.string.network_message_406);
            case 416:
                return getString(R.string.network_message_416);
            case 418:
                return getString(R.string.network_message_418);
            case 419:
                return getString(R.string.network_message_419);
            case 422:
                return getString(R.string.network_message_422);
            case 430:
                return getString(R.string.network_message_430);
            case 440:
                return getString(R.string.network_message_440);
            case 441:
                return getString(R.string.network_message_441);
            case ERROR_CODE_TOKEN_EXPIRED:
            case ERROR_CODE_TOKEN_EMPTY:
                return getString(R.string.network_message_450);
            case 472:
                return getString(R.string.network_message_472);
            case 481:
                return getString(R.string.network_message_481);
            case 500:
                return getString(R.string.network_message_500);
            case 504:
                return getString(R.string.network_message_504);
            case 506:
                return getString(R.string.network_message_506);
            case 541:
                return getString(R.string.network_message_541);
            case 560:
                return getString(R.string.network_message_560);
            case 611:
                return getString(R.string.network_message_611);
            case 622:
            case 630:
                return getString(R.string.network_message_622);
            case 632:
                return getString(R.string.network_message_632);
            case 634:
                return getString(R.string.network_message_634);
            case 643:
                return getString(R.string.network_message_643);
            case 642:
            case 644:
                return getString(R.string.network_message_644);
            case 645:
                return getString(R.string.network_message_645);
            case 702:
                return getString(R.string.network_message_702);
            case 800:
            case 801:
                return getString(R.string.network_message_801);
            case 802:
                return getString(R.string.network_message_802);
            case 804:
                return getString(R.string.network_message_804);
            case 805:
                return getString(R.string.network_message_805);
            case 806:
                return getString(R.string.network_message_806);
            default:
                return message;
        }
    }

    public static boolean shouldLeaveRoom(int error) {
        return error == 422 || error == 472;
    }

    protected static String getString(int res) {
        return AppUtil.getApplicationContext().getString(res);
    }
}