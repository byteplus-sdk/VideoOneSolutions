package com.vertcdemo.core.chat.bean;

import com.vertcdemo.core.chat.annotation.GiftType;

public interface IGiftEvent {
    @GiftType
    int getGiftType();

    String getUserId();

    String getUserName();

    int getCount();
}
