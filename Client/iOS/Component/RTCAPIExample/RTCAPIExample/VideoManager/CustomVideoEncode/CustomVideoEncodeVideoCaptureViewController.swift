//
//  CustomVideoCaptureViewController.swift
//  ApiExample
//
//  Created by bytedance on 2024/3/21.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit
import SnapKit
import BytePlusRTC

@objc(CustomVideoEncodeVideoCaptureViewController)
class CustomVideoEncodeVideoCaptureViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate, ByteRTCExternalVideoEncoderEventHandler {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom: ByteRTCRoom?
    var users : Array = Array<ByteRTCRemoteStreamKey>()
    
    var timer: GCDTimer?
    var decoder: VideoDecoder?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
        self.buildActions()
    }
    
    deinit {
        
        self.rtcRoom?.leaveRoom()
        self.rtcRoom?.destroy()
        self.rtcRoom = nil
        
        ByteRTCVideo.destroyRTCVideo()
        self.rtcVideo = nil
    }
    
    // MARK: Private method
    
    @objc func joinRoom()  {
        let roomId = self.roomSettingItem.text ?? ""
        let userId = self.userSettingItem.text ?? ""
        
        var vaild = checkValid(roomId)
        if vaild == false {
            ToastComponents.shared.show(withMessage: LocalizedString("toast_check_valid_false"))
            return
        }
        
        vaild = checkValid(userId)
        if vaild == false {
            ToastComponents.shared.show(withMessage: LocalizedString("toast_check_valid_false"))
            return
        }
        
        joinButton.isSelected = !joinButton.isSelected

        if joinButton.isSelected {
            generateToken(roomId: roomId, userId: userId) { [weak self] token in
                self?.joinButton.setTitle(LocalizedString("button_leave_room"), for: .normal)
                // Join room
                self?.rtcRoom = self?.rtcVideo?.createRTCRoom(roomId)
                self?.rtcRoom?.delegate = self

                let userInfo = ByteRTCUserInfo.init()
                userInfo.userId = userId

                let roomCfg = ByteRTCRoomConfig.init()
                roomCfg.isAutoPublish = true
                roomCfg.isAutoSubscribeAudio = true
                roomCfg.isAutoSubscribeVideo = true

                self?.rtcRoom?.joinRoom(token, userInfo: userInfo, roomConfig: roomCfg)
            }
        }
        else {
            joinButton.setTitle(LocalizedString("button_join_room"), for: .normal)
            self.rtcRoom?.leaveRoom()
        }
    }
    
    func buildRTCEngine() {
        // Create engine.
        self.rtcVideo = ByteRTCVideo.createRTCVideo(rtcAppId(), delegate: self, parameters: [:])
        
        // Start local audio capture.
        self.rtcVideo?.startAudioCapture()
        
        // Enable external video source.
        self.rtcVideo?.setVideoSourceType(.encodedAutoSimulcast, WithStreamIndex: .indexMain)
        
        weak var weakSelf = self
        self.rtcVideo?.setExternalVideoEncoderEventHandler(weakSelf)

        // Read the local video file.
        if let mp4FilePath = Bundle.main.path(forResource: "test_codec", ofType: "mp4") {
            print("--------------mp4 file path :\(mp4FilePath)")
            
            let url = URL(fileURLWithPath: mp4FilePath)
            self.decoder = VideoDecoder(url: url)
        } else {
            print("No such file found")
        }
        
        
        self.bindLocalRenderView()
    }
    
    func bindLocalRenderView() {
        // Set local user render view.
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.localView.videoView
        canvas.renderMode = .hidden
        self.localView.userId = userSettingItem.text ?? ""
        
        self.rtcVideo?.setLocalVideoCanvas(.indexMain, withCanvas: canvas);
    }
    
    func updateRenderView() {
        // Get the first remote user.
        var remoteUser:ByteRTCRemoteStreamKey?
        
        for streamKey in self.users {
            if remoteUser == nil && streamKey.roomId ==  self.roomSettingItem.text {
                remoteUser = streamKey
            }
        }
        
        if (remoteUser != nil) {
            self.bindRemoteRenderView(view: self.firstRemoteView,roomId: (remoteUser?.roomId)!,userId: (remoteUser?.userId)!)
        }
    }
    
    func buildActions() {
    }
    
    @objc func startPush() {
        if (self.timer != nil) {
            self.timer?.cancel()
            self.timer = nil
        }
        
        weak var weakSelf = self

        // Start a timer to push data at 30ms intervals.
        self.timer = GCDTimer(interval: .milliseconds(30)) {
            weakSelf?.pushExternalEncodeVideo()
        }
        
        self.timer!.start()
    }
    
    @objc func pushExternalEncodeVideo() {
        
        guard let decoder = self.decoder else {
            print("_decoder is nil")
            return
        }

        let index = 0
        let w:Int32 = 640
        let h:Int32 = 360

        if (w <= 0 || h <= 0) {
            return
        }

        var isKeyFrame = false

        var frame = decoder.nextFrame(&isKeyFrame)
        
        self.pushEncodeFrame(index: index, width: w, height: h, data: frame!, keyFrame: isKeyFrame)
    }

    func pushEncodeFrame(index: Int, width: Int32, height: Int32, data: Data, keyFrame: Bool) -> Bool {
        if (data.count <= 0) {
            print("data is null")
            return false
        }

        let encodeFrame = ByteRTCEncodedVideoFrame()
        encodeFrame.codecType = .H264

        if keyFrame {
            print("------------ push i frame")
            encodeFrame.pictureType = .I
        } else {
            encodeFrame.pictureType = .P
        }

        encodeFrame.width = width
        encodeFrame.height = height
        encodeFrame.data = data
        encodeFrame.timestampUs = decoder!.pts
        encodeFrame.timestampDtsUs = decoder!.dts
        
        self.rtcVideo?.pushExternalEncodedVideoFrame(.indexMain, withVideoIndex: 0, withEncodedVideoFrame: encodeFrame)

        return true
    }
    
    @objc func stopPush() {
        if (self.timer != nil) {
            self.timer?.cancel()
            self.timer = nil
        }
    }
    
    func bindRemoteRenderView(view: UserVideoView, roomId: String, userId: String) {
        // Set remote user render view.
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = view.videoView
        canvas.renderMode = .hidden
        view.userId = userId

        let streamKey = ByteRTCRemoteStreamKey.init()
        streamKey.userId = userId;
        streamKey.roomId = roomId;
        streamKey.streamIndex = .indexMain
        
        self.rtcVideo?.setRemoteVideoCanvas(streamKey, withCanvas: canvas)
    }
    
    func createUI() -> Void {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(containerView.snp.width)
        }
        
        self.containerView.addSubview(localView)
        self.containerView.addSubview(firstRemoteView)
        self.localView.snp.makeConstraints { make in
            make.left.top.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }
        
        self.firstRemoteView.snp.makeConstraints { make in
            make.right.bottom.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }

        view.addSubview(roomSettingItem)
        view.addSubview(userSettingItem)
        view.addSubview(joinButton)
        
        roomSettingItem.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        userSettingItem.snp.makeConstraints { make in
            make.centerY.equalTo(roomSettingItem)
            make.left.equalTo(roomSettingItem.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(roomSettingItem)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(roomSettingItem.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(36)
        }
        
        view.addSubview(startButton)
        view.addSubview(stopButton)

        startButton.snp.makeConstraints { make in
            make.top.equalTo(joinButton.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        stopButton.snp.makeConstraints { make in
            make.centerY.equalTo(startButton)
            make.left.equalTo(startButton.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(startButton)
        }
    }
    
    // MARK: Lazy laod
    
    lazy var roomSettingItem: TextFieldView = {
        let settingView = TextFieldView()
        settingView.title = LocalizedString("hint_room_id")
        return settingView
    }()
    
    lazy var userSettingItem: TextFieldView = {
        let settingView = TextFieldView()
        settingView.title = LocalizedString("hint_user_id")
        return settingView
    }()
    
    lazy var joinButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_join_room"), for: .normal)
        button.addTarget(self, action: #selector(joinRoom), for: .touchUpInside)
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = UIView.init()
        view.backgroundColor = .groupTableViewBackground
        return view
    }()
    
    lazy var localView: UserVideoView = {
        let view = UserVideoView.init()
        return view
    }()
    
    lazy var firstRemoteView: UserVideoView = {
        let view = UserVideoView.init()
        return view
    }()
    
    lazy var startButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_start"), for: .normal)
        button.addTarget(self, action: #selector(startPush), for: .touchUpInside)
        return button
    }()
    
    lazy var stopButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_stop"), for: .normal)
        button.addTarget(self, action: #selector(stopPush), for: .touchUpInside)
        return button
    }()
    
    // MARK: ByteRTCVideoDelegate & ByteRTCRoomDelegate
    // Enter room status.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        ToastComponents.shared.show(withMessage: "onRoomStateChanged uid: \(uid) state:\(state)")
        
    }

    // Remote user publishing stream.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserPublishStream userId: String, type: ByteRTCMediaStreamType) {
        ToastComponents.shared.show(withMessage: "onUserPublishStream uid: \(userId)")
        
        if type == .video || type == .both {
            
            let streamKey = ByteRTCRemoteStreamKey.init()
            streamKey.userId = userId;
            streamKey.roomId = rtcRoom.getId();
            streamKey.streamIndex = .indexMain
            
            self.users.append(streamKey)
            
            DispatchQueue.main.async {
                self.updateRenderView()
            }
        }
    }

     // Remote user cancel publish stream.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserUnpublishStream userId: String, type: ByteRTCMediaStreamType, reason: ByteRTCStreamRemoveReason) {
        ToastComponents.shared.show(withMessage: "onUserUnpublishStream uid: \(userId)")
        
        if type == .video || type == .both {
            var itemsToRemove: [ByteRTCRemoteStreamKey] = []
            
            for streamKey in self.users {
                if streamKey.userId == userId {
                    itemsToRemove.append(streamKey)
                }
            }
            
            for item in itemsToRemove {
                if let index = self.users.firstIndex(of: item) {
                    self.users.remove(at: index)
                }
            }
            
            DispatchQueue.main.async {
                for videoView in self.containerView.subviews {
                    if let view = videoView as? UserVideoView {
                        let userId = view.userId
                        
                        if userId == userId {
                            view.userId = ""
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.updateRenderView()
            }
        }
    }

    // Remote user joined the room.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserJoined userInfo: ByteRTCUserInfo, elapsed: Int) {
        ToastComponents.shared.show(withMessage: "onUserJoined uid: \(userInfo.userId)")
        
    }

    // Remote user leave the room.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserLeave uid: String, reason: ByteRTCUserOfflineReason) {
        ToastComponents.shared.show(withMessage: "onUserLeave uid: \(uid)")
        
    }
    
    // MARK: ByteRTCExternalVideoEncoderEventHandler
    func onStart(_ streamIndex: ByteRTCStreamIndex) {
        print("VideoEncoderEventHandler == onStart")
        self.startPush()
    }
    
    func onStop(_ streamIndex: ByteRTCStreamIndex) {
        print("VideoEncoderEventHandler == onStop")

    }
    
    func onRateUpdate(_ streamIndex: ByteRTCStreamIndex, withVideoIndex videoIndex: Int, withFps fps: Int, withBitRate bitRateKps: Int) {
        print("VideoEncoderEventHandler == onRateUpdate")
    }
    
    func onRequestKeyFrame(_ streamIndex: ByteRTCStreamIndex, withVideoIndex videoIndex: Int) {
        print("VideoEncoderEventHandler == onRequestKeyFrame")

        let w:Int32 = 640
        let h:Int32 = 360
        if let decoder = decoder {
            var frame = decoder.getKeyFrame()
            self.pushEncodeFrame(index: streamIndex.rawValue, width: w, height: h, data: frame!, keyFrame: true)
        }
    }
    
    func onActiveVideoLayer(_ streamIndex: ByteRTCStreamIndex, withVideoIndex videoIndex: Int, withActive active: Bool) {
        print("VideoEncoderEventHandler == onActiveVideoLayer")

    }
}
