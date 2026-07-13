
import UIKit
import AVKit
import SnapKit
import BytePlusRTC

@objc(ScreenShareViewController)
class ScreenShareViewController: BaseViewController, ByteRTCEngineDelegate, ByteRTCRoomDelegate {
    
    var rtcVideo: ByteRTCEngine?
    var rtcRoom: ByteRTCRoom?
    var userVideoStreamMap: Dictionary = Dictionary<String, ByteRTCStreamInfo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
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

                // Join the room.
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
    
    @objc func startScreenShare()  {
        shareButton.isSelected = !shareButton.isSelected

        if shareButton.isSelected {
            let screehShareUserDefaults = UserDefaults(suiteName: AppGroupId)
            screehShareUserDefaults?.set("rtc", forKey: "shareType")
            screehShareUserDefaults?.synchronize()
            self.rtcVideo?.startScreenCapture(ByteRTCScreenMediaType.videoAndAudio, bundleId: ExtensionBundleId)
        } else {
            self.rtcVideo?.stopScreenCapture()
        }
    }
    
    func buildRTCEngine() {
        // Create engine.
        let engineCfg = ByteRTCEngineConfig.init()
        engineCfg.appID = rtcAppId()
        engineCfg.parameters = [:]
        self.rtcVideo = ByteRTCEngine.createRTCEngine(engineCfg, delegate: self)

        self.rtcVideo?.startVideoCapture()
        self.rtcVideo?.startAudioCapture()
        
        self.bindLocalRenderView()

        // Set screen share group info.
        self.rtcVideo?.setExtensionConfig(AppGroupId)
    }
    
    func bindLocalRenderView() {
        // Set local video render view.
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.localView.videoView
        canvas.renderMode = .hidden
        self.localView.userId = userSettingItem.text ?? ""
        
        self.rtcVideo?.setLocalVideoCanvas(withCanvas: canvas);
    }
    
    func updateRenderView() {
        var remoteStreamInfo:ByteRTCStreamInfo?
                
        for (userId, info) in self.userVideoStreamMap {
            if info.roomId == self.roomSettingItem.text {
                remoteStreamInfo = info
            }
        }
        
        if (remoteStreamInfo != nil) {
            self.bindRemoteRenderView(view: self.firstRemoteView, roomId:remoteStreamInfo!.roomId, userId:remoteStreamInfo!.userId)
        }
    }
    
    func bindRemoteRenderView(view: UserVideoView, roomId: String, userId: String) {
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
        self.containerView.addSubview(localView)
        self.containerView.addSubview(firstRemoteView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(containerView.snp.width)
            make.left.right.equalTo(self.view)
        }
        
        self.localView.snp.makeConstraints { make in
            make.left.top.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }
        
        self.firstRemoteView.snp.makeConstraints { make in
            make.top.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }
        
        view.addSubview(roomSettingItem)
        view.addSubview(userSettingItem)
        view.addSubview(joinButton)
        view.addSubview(shareButton)
        
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
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(joinButton.snp.bottom).offset(10)
            make.left.right.width.height.equalTo(joinButton)
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
    
    lazy var shareButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("example_start_screen_share"), for: .normal)
        button.addTarget(self, action: #selector(startScreenShare), for: .touchUpInside)
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
    
    // MARK: ByteRTCVideoDelegate & ByteRTCRoomDelegate
    // Enter room status.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        ToastComponents.shared.show(withMessage: "onRoomStateChanged uid: \(uid) state:\(state)")
        
    }
    
    func rtcRoom(_ rtcRoom:ByteRTCRoom, onUserPublishStreamVideo streamId:String,info:ByteRTCStreamInfo,isPublish:Bool){
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
        }
        
    }


    // Screen sharing status.
    func rtcEngine(_ engine: ByteRTCEngine, onVideoDeviceStateChanged deviceID: String, device_type deviceType: ByteRTCVideoDeviceType, device_state deviceState: ByteRTCMediaDeviceState, device_error deviceError: ByteRTCMediaDeviceError) {
        
        if deviceType == .screenCaptureDevice {
            if deviceState == .stateStarted {
                // Screen sharing started.
                ToastComponents.shared.show(withMessage: "screen share start")
                DispatchQueue.main.async {
                    self.shareButton.isSelected = true
                    self.shareButton .setTitle(LocalizedString("example_end_sharing"), for: .normal)
                }
                
            } else if deviceState == .stateStopped || deviceState == .stateRuntimeError {
                ToastComponents.shared.show(withMessage: "screen share stop")
                DispatchQueue.main.async {
                    self.shareButton.isSelected = false
                    self.shareButton .setTitle(LocalizedString("example_start_sharing"), for: .normal)
                }
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
}

