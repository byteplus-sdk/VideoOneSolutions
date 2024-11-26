
import UIKit
import AVKit
import SnapKit
import BytePlusRTC

@objc(CustomVideoRenderViewController)
class CustomVideoRenderViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate, AVPictureInPictureControllerDelegate {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom: ByteRTCRoom?
    var users : Array = Array<ByteRTCRemoteStreamKey>()
    
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
        
        // Start local video and audio capture.
        self.rtcVideo?.startVideoCapture()
        self.rtcVideo?.startAudioCapture()
        
        self.bindLocalRenderView()
    }
    
    func buildActions() {
        weak var weakSelf = self

        // Set local video render format.
        self.renderFormatSheetView.didSelectOption = {(value) in
            let config = ByteRTCLocalVideoSinkConfig.init()
            if (value == 0) {
                config.requiredPixelFormat = .BGRA
            } else {
                config.requiredPixelFormat = .NV12
            }
            
            weakSelf?.rtcVideo?.setLocalVideoRender(.indexMain, withSink: self.customRenderView, withLocalRenderConfig: config)
        }
    }
    
    func bindLocalRenderView() {
        // Set local video render view.
        let config = ByteRTCLocalVideoSinkConfig.init()
        config.requiredPixelFormat = .original
        config.position = .afterCapture
        
        self.rtcVideo?.setLocalVideoRender(.indexMain, withSink: self.customRenderView, withLocalRenderConfig: config)
    }
    
    func updateRenderView() {
        var remoteUser:ByteRTCRemoteStreamKey?
        
        for streamKey in self.users {
            if remoteUser == nil && streamKey.roomId ==  self.roomSettingItem.text {
                remoteUser = streamKey
            }
        }
        if (remoteUser != nil) {
            let roomId = remoteUser!.roomId!
            let userId = remoteUser!.userId!
            
            self.bindRemoteRenderView(view: self.customRenderView,roomId: roomId,userId: userId)
        }
    }
    
    func bindRemoteRenderView(view: CustomVideoRenderView, roomId: String, userId: String) {
        let streamKey = ByteRTCRemoteStreamKey.init()
        streamKey.userId = userId;
        streamKey.roomId = roomId;
        streamKey.streamIndex = .indexMain
        
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.remoteRenderView.videoView
        canvas.renderMode = .hidden
        self.remoteRenderView.userId = userId
        
        self.rtcVideo?.setRemoteVideoCanvas(streamKey, withCanvas: canvas)
    }
    
    func createUI() -> Void {
        view.addSubview(containerView)
        self.containerView.addSubview(remoteRenderView)
        self.containerView.addSubview(customRenderView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(containerView.snp.width)
            make.left.right.equalTo(self.view)
        }
        
        self.customRenderView.snp.makeConstraints { make in
            make.left.top.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }
        
        self.remoteRenderView.snp.makeConstraints { make in
            make.top.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.width.equalTo(self.containerView).multipliedBy(0.5)
        }
        
        view.addSubview(renderFormatSheetView)
        renderFormatSheetView.snp.makeConstraints { make in
            make.top.equalTo(customRenderView.snp.bottom).offset(10)
            make.left.equalTo(customRenderView)
            make.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(roomSettingItem)
        view.addSubview(userSettingItem)
        view.addSubview(joinButton)
        
        roomSettingItem.snp.makeConstraints { make in
            make.top.equalTo(renderFormatSheetView.snp.bottom).offset(20)
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
    
    lazy var remoteUserIdLabel: UILabel = {
        let label = UILabel.init()
        label.textAlignment = .center
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView.init()
        view.backgroundColor = .groupTableViewBackground
        return view
    }()
    
    lazy var remoteRenderView: UserVideoView = {
        let view = UserVideoView.init()
        return view
    }()
    
    lazy var customRenderView: CustomVideoRenderView = {
        let view = CustomVideoRenderView.init(frame: CGRectZero)
        return view
    }()
    
    lazy var renderFormatSheetView: ActionSheetView = {
        let actionSheetView = ActionSheetView.init(title: LocalizedString("example_video_render_format"), optionArray: ["RGBA","CVPixelBuffer"], defaultIndex: 0)
        actionSheetView.presentingViewController = self
        
        return actionSheetView
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
}

