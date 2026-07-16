package com.vertc.api.example.examples.video;

import androidx.lifecycle.ViewModel;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCEngine;

public class VideoRotateConfigViewModel extends ViewModel {
    public RTCEngine rtcVideo;
    public RTCRoom rtcRoom;
    public String roomId;

    public String remoteUserId;
    public String remoteStreamId;

    public boolean isJoined = false;

    public void setRtcRoom(RTCRoom room) {
        leaveRoom();
        rtcRoom = room;
    }

    public void leaveRoom() {
        if (rtcRoom != null) {
            rtcRoom.leaveRoom();
            rtcRoom.destroy();
            rtcRoom = null;
            remoteUserId = null;
            remoteStreamId = null;
        }
    }

    public void destroy() {
        leaveRoom();
        rtcVideo = null;
        RTCEngine.destroyRTCEngine();
    }
}
