
import UIKit
import AVKit
import SnapKit
import BytePlusRTC

@objc(ScreenShareViewController)
class ScreenShareViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom: ByteRTCRoom?
    var users : Array = Array<ByteRTCRemoteStreamKey>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
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

                // Join the room.
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
        self.rtcVideo = ByteRTCVideo.createRTCVideo(rtcAppId(), delegate: self, parameters: [:])
        
        // Start local video and audio capture.
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
        
        self.rtcVideo?.setLocalVideoCanvas(.indexMain, withCanvas: canvas);
    }
    
    func updateRenderView() {
        var remoteUser:ByteRTCRemoteStreamKey?
        
        for streamKey in self.users {
            if remoteUser == nil && streamKey.roomId ==  self.roomSettingItem.text {
                remoteUser = streamKey
            }
        }
        
        if (remoteUser != nil) {
            self.bindRemoteRenderView(streamKey: remoteUser!)
        }
    }
    
    func bindRemoteRenderView(streamKey: ByteRTCRemoteStreamKey) {
        
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.firstRemoteView.videoView
        canvas.renderMode = .hidden
        self.firstRemoteView.userId = streamKey.userId ?? ""
        
        self.rtcVideo?.setRemoteVideoCanvas(streamKey, withCanvas: canvas)
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

    // Remote user puhlishing stream.
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
                if streamKey.userId == userId && streamKey.streamIndex == .indexMain{
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

    // Remote user publishes screen stream.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserPublishScreen userId: String, type: ByteRTCMediaStreamType) {
        ToastComponents.shared.show(withMessage: "onUserPublishScreen uid: \(userId)")
        
        if type == .video || type == .both {
            
            let streamKey = ByteRTCRemoteStreamKey.init()
            streamKey.userId = userId;
            streamKey.roomId = rtcRoom.getId();
            streamKey.streamIndex = .indexScreen
            
            self.users.append(streamKey)
            
            DispatchQueue.main.async {
                self.updateRenderView()
            }
        }
    }

    // Remote user stops publishing screen stream.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onUserUnpublishScreen userId: String, type: ByteRTCMediaStreamType, reason: ByteRTCStreamRemoveReason) {
        ToastComponents.shared.show(withMessage: "onUserUnpublishScreen uid: \(userId)")
        
        if type == .video || type == .both {
            var itemsToRemove: [ByteRTCRemoteStreamKey] = []
            
            for streamKey in self.users {
                if streamKey.userId == userId && streamKey.streamIndex == .indexScreen{
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

    // Screen sharing status.
    func rtcEngine(_ engine: ByteRTCVideo, onVideoDeviceStateChanged deviceID: String, device_type deviceType: ByteRTCVideoDeviceType, device_state deviceState: ByteRTCMediaDeviceState, device_error deviceError: ByteRTCMediaDeviceError) {
        
        if deviceType == .screenCaptureDevice {
            if deviceState == .stateStarted {
                // Screen sharing started.
                self.rtcRoom?.publishScreen(ByteRTCMediaStreamType.video)
                
                
                DispatchQueue.main.async {
                    self.shareButton.isSelected = true
                    self.shareButton .setTitle(LocalizedString("example_end_sharing"), for: .normal)
                    self.rtcRoom?.unpublishStream(ByteRTCMediaStreamType.video)
                }
                
            } else if deviceState == .stateStopped || deviceState == .stateRuntimeError {
                self.rtcRoom?.unpublishScreen(ByteRTCMediaStreamType.both)

                DispatchQueue.main.async {
                    self.shareButton.isSelected = false
                    self.shareButton .setTitle(LocalizedString("example_start_sharing"), for: .normal)
                    self.rtcRoom?.publishStream(ByteRTCMediaStreamType.video)
                }
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
}

