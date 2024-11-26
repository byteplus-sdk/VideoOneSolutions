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

@objc(CustomVideoCaptureViewController)
class CustomVideoCaptureViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate, CameraDelegate {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom: ByteRTCRoom?
    var users : Array = Array<ByteRTCRemoteStreamKey>()
    
    var customCamera: CustomVideoCapture?
    
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
        self.rtcVideo?.setVideoSourceType(.external, WithStreamIndex: .indexMain)
        self.customCamera = CustomVideoCapture()
        self.customCamera?.delegate = self
        
        self.customCamera?.start()
        
        self.bindLocalRenderView()
    }
    
    func bindLocalRenderView() {
        // Set local render view.
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.localView.videoView
        canvas.renderMode = .hidden
        self.localView.userId = userSettingItem.text ?? ""
        
        self.rtcVideo?.setLocalVideoCanvas(.indexMain, withCanvas: canvas);
    }
    
    func updateRenderView() {
        // Get the first remote user in the room.
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
        weak var weakSelf = self
        self.captureFormatSheetView.didSelectOption = {(value) in

            if (value == 0) {
                weakSelf?.customCamera?.updateFormat(to: kCVPixelFormatType_32BGRA)
                ToastComponents.shared.show(withMessage: "BGRA")

            } else {
                weakSelf?.customCamera?.updateFormat(to: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                ToastComponents.shared.show(withMessage: "NV12")
            }
            
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

        view.addSubview(captureFormatSheetView)
        captureFormatSheetView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(10)
            make.left.equalTo(containerView)
            make.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(roomSettingItem)
        view.addSubview(userSettingItem)
        view.addSubview(joinButton)
        
        roomSettingItem.snp.makeConstraints { make in
            make.top.equalTo(captureFormatSheetView.snp.bottom).offset(10)
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
    
    lazy var captureFormatSheetView: ActionSheetView = {
        let actionSheetView = ActionSheetView.init(title: LocalizedString("example_video_capture_format"), optionArray: ["BGRA","NV12"], defaultIndex: 0)
        actionSheetView.presentingViewController = self
        
        return actionSheetView
    }()
    
    // MARK: ByteRTCVideoDelegate & ByteRTCRoomDelegate
    // Room status.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        ToastComponents.shared.show(withMessage: "onRoomStateChanged uid: \(uid) state:\(state)")
        
    }
    // Remote user publish stream.
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
     // Remote user cancel stream.
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
    
    func camera(_ camera: CustomVideoCapture, didOutput sampleBuffer: CMSampleBuffer) {
        
        self.pushExternalVideoFrame(sampleBuffer)
    }
    
    func pushExternalVideoFrame(_  sampleBuffer: CMSampleBuffer) {
        
        guard let pixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let newFrame = ByteRTCVideoFrame()
        newFrame.format = 12
        newFrame.contentType = .normalFrame
        newFrame.time = getCMTime()
        newFrame.width = Int32(CVPixelBufferGetWidth(pixelBufferRef))
        newFrame.height = Int32(CVPixelBufferGetHeight(pixelBufferRef))
        newFrame.textureBuf = pixelBufferRef
        newFrame.rotation = .rotation90
        newFrame.extendedData = nil
        // Push video frame to RTC.
        rtcVideo?.pushExternalVideoFrame(newFrame)
    }
    
    func getCMTime() -> CMTime {
        let value = Int64(CACurrentMediaTime() * 1000000000)
        let time = CMTimeMake(value: value, timescale: 1000000000)
        return time
    }
}

