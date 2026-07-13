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
class CustomVideoCaptureViewController: BaseViewController, ByteRTCEngineDelegate, ByteRTCRoomDelegate, CameraDelegate {
    
    var rtcVideo: ByteRTCEngine?
    var rtcRoom: ByteRTCRoom?
    var userVideoStreamMap: Dictionary = Dictionary<String, ByteRTCStreamInfo>()

    
    var customCamera: CustomVideoCapture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
        self.buildActions()
    }
    
    deinit {
        
        self.rtcRoom?.leave()
        self.rtcRoom?.destroy()
        self.rtcRoom = nil
        
        ByteRTCEngine.destroyRTCEngine()
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
                roomCfg.isPublishAudio = true
                roomCfg.isPublishVideo = true
                roomCfg.isAutoSubscribeAudio = true
                roomCfg.isAutoSubscribeVideo = true

                self?.rtcRoom?.joinRoom(token, userInfo: userInfo, userVisibility: true, roomConfig: roomCfg)
            }
        }
        else {
            joinButton.setTitle(LocalizedString("button_join_room"), for: .normal)
            self.rtcRoom?.leave()
        }
    }
    
    func buildRTCEngine() {
        // 创建引擎
        let engineCfg = ByteRTCEngineConfig.init()
        engineCfg.appID = rtcAppId()
        engineCfg.parameters = [:]
        self.rtcVideo = ByteRTCEngine.createRTCEngine(engineCfg, delegate: self)

        // 开启本地音视频采集
        self.rtcVideo?.startAudioCapture()
        
        // 开启自定义采集
        self.rtcVideo?.setVideoSourceType(.external)
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
        
        self.rtcVideo?.setLocalVideoCanvas(withCanvas: canvas);
    }
    
    func updateRenderView() {
        // Get the first remote user in the room.
        var roomId: String?
        var remoteUserId: String?
        
        for (_, info) in self.userVideoStreamMap {
            roomId = info.roomId
            remoteUserId = info.userId
            break
        }
        
        if let remoteUserId = remoteUserId, let roomId = roomId {
            self.bindRemoteRenderView(view: self.firstRemoteView, roomId: roomId, userId: remoteUserId)
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
        var streamInfo = self.userVideoStreamMap[userId]
        if streamInfo == nil {
            return
        }
        var streamId = streamInfo?.streamId
        if streamId == nil {
            return
        }
        
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = view.videoView
        canvas.renderMode = .hidden
        view.userId = userId
        
        self.rtcVideo?.setRemoteVideoCanvas(streamId!, withCanvas: canvas)
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
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserPublishStreamVideo streamId: String, info: ByteRTCStreamInfo, isPublish: Bool) {
        ToastComponents.shared.show(withMessage: "onUserPublishStream uid: \(info.userId), isPub: \(isPublish)")
        
        if isPublish {
            
            self.userVideoStreamMap.updateValue(info, forKey: info.userId)
            
            DispatchQueue.main.async {
                self.updateRenderView()
            }
        } else {
            self.userVideoStreamMap.removeValue(forKey: info.userId)
            
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
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserJoined userInfo: ByteRTCUserInfo) {
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
        
        let newFrame = ByteRTCVideoFrameData()
        newFrame.bufferType = .cvPixelBuffer
        newFrame.timestamp = getCMTime()
        newFrame.width = Int32(CVPixelBufferGetWidth(pixelBufferRef))
        newFrame.height = Int32(CVPixelBufferGetHeight(pixelBufferRef))
        newFrame.cvpixelbuffer = pixelBufferRef
        newFrame.rotation = .rotation90
        newFrame.seiData = nil
        
        rtcVideo?.pushExternalVideoFrame(newFrame)
    }
    
    func getCMTime() -> CMTime {
        let value = Int64(CACurrentMediaTime() * 1000000000)
        let time = CMTimeMake(value: value, timescale: 1000000000)
        return time
    }
}

