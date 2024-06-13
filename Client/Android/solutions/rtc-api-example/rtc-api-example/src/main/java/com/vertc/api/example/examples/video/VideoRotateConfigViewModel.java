package com.vertc.api.example.examples.video;

import androidx.lifecycle.ViewModel;

import com.ss.bytertc.engine.RTCRoom;
import com.ss.bytertc.engine.RTCVideo;

public class VideoRotateConfigViewModel extends ViewModel {
    public RTCVideo rtcVideo;
    public RTCRoom rtcRoom;
    public String roomId;

    public String remoteUserId;

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
        }
    }

    public void destroy() {
        leaveRoom();
        rtcVideo = null;
        RTCVideo.destroyRTCVideo();
    }
}
