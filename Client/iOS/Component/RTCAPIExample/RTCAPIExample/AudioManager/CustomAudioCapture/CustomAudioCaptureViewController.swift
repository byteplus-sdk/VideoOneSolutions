
import UIKit
import SnapKit
import BytePlusRTC

@objc(CustomAudioCaptureViewController)
class CustomAudioCaptureViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom1: ByteRTCRoom?
    var firstPush:Bool = true
    var timer: GCDTimer?
    var startOffset = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
        self.bindLocalRenderView()
        self.buildActions()
    
    }
    
    deinit {
        self.rtcVideo!.registerAudioFrameObserver(nil)

        self.rtcRoom1?.leaveRoom()
        self.rtcRoom1?.destroy()
        self.rtcRoom1 = nil
        
        ByteRTCVideo.destroyRTCVideo()
        self.rtcVideo = nil
    }
    
    // MARK: Private method
    
    @objc func joinRoom()  {
        let roomId = self.roomTextField.text ?? ""
        let userId = self.userTextField.text ?? ""
        
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
                self?.rtcRoom1 = self?.rtcVideo?.createRTCRoom(roomId)
                self?.rtcRoom1?.delegate = self

                let userInfo = ByteRTCUserInfo.init()
                userInfo.userId = userId

                let roomCfg = ByteRTCRoomConfig.init()
                roomCfg.isAutoPublish = true
                roomCfg.isAutoSubscribeAudio = true
                roomCfg.isAutoSubscribeVideo = true

                self?.rtcRoom1?.joinRoom(token, userInfo: userInfo, roomConfig: roomCfg)
            }
        }
        else {
            joinButton.setTitle(LocalizedString("button_join_room"), for: .normal)
            self.rtcRoom1?.leaveRoom()
        }
    }
    
    func buildRTCEngine() {
        // Create engine.
        self.rtcVideo = ByteRTCVideo.createRTCVideo(rtcAppId(), delegate: self, parameters: [:])
        
        // Start local video capture.
        self.rtcVideo?.startVideoCapture()
        
        // Enable external audio source.
        self.rtcVideo?.setAudioSourceType(.external)
        
        self.bindLocalRenderView()
    }
    
    func buildActions() {
        
    }
    
    func bindLocalRenderView() {
        // Set local render view.
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.localView.videoView
        canvas.renderMode = .hidden
        self.localView.userId = userTextField.text ?? ""
        
        self.rtcVideo?.setLocalVideoCanvas(.indexMain, withCanvas: canvas);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func startPush() {
        self.startOffset = 0
        
        if (self.timer != nil) {
            self.timer?.cancel()
            self.timer = nil
        }
        
        weak var weakSelf = self
        // Start timer to push data at 10ms intervals.
        self.timer = GCDTimer(interval: .milliseconds(10)) {
            weakSelf!.pushPCMData()
        }
        
        self.timer!.start()
    }
    
    func pushPCMData() {
        // The data for every 10ms is equal to the (number of samples) * (number of channels) * (bytes per sample). This PCM file has a sample rate of 16000, mono, with each sample occupying 2 bytes.
        let size = 160 * 1 * 2
        
        if self.firstPush {
            self.firstPush = false
        }
        
        let filePath = Bundle.main.path(forResource: "rtc_audio_16k_mono", ofType: "pcm")!
        let url = URL(fileURLWithPath: filePath)
        
        guard let fileData = try? Data(contentsOf: url) else {
            print("Failed to read PCM file data.")
            return
        }
        
        var endOffset = self.startOffset + size
        
        if endOffset >= fileData.count {
            // Read data from the beginging again.
            self.startOffset = 0
            endOffset = self.startOffset + size
        }
        
        let audioData: Data = fileData.subdata(in: startOffset..<endOffset)
        self.startOffset = endOffset
        
        let audioFrame = ByteRTCAudioFrame()
        audioFrame.channel = .mono
        audioFrame.sampleRate = .rate16000
        // Each sample occupies 2 bytes.
        audioFrame.samples = Int32(size) / 2
        audioFrame.buffer = audioData
        
        self.rtcVideo?.pushExternalAudioFrame(audioFrame)
    }
    
    @objc func stopPush() {
        self.timer?.cancel()
    }
    
    func createUI() -> Void {
        view.addSubview(containerView)
        self.containerView.addSubview(localView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom)
            make.left.right.equalTo(self.view)
        }
        
        self.localView.snp.makeConstraints { make in
            make.left.top.equalTo(self.containerView)
            make.width.height.equalTo(self.containerView)
        }
        
        view.addSubview(roomLabel)
        view.addSubview(roomTextField)
        view.addSubview(userLabel)
        view.addSubview(userTextField)
        view.addSubview(joinButton)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
        }
        
        roomTextField.snp.makeConstraints { make in
            make.centerY.equalTo(roomLabel)
            make.left.equalTo(roomLabel.snp.right).offset(10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        userLabel.snp.makeConstraints { make in
            make.centerY.equalTo(roomLabel)
        }
        
        userTextField.snp.makeConstraints { make in
            make.centerY.equalTo(roomLabel)
            make.left.equalTo(userLabel.snp.right).offset(10)
            make.right.equalTo(view).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(roomLabel.snp.bottom).offset(20)
            make.left.equalTo(roomLabel)
            make.right.equalTo(view).offset(-10)
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
    lazy var roomLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString("hint_room_id")
        return label
    }()
    
    lazy var roomTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString("hint_user_id")
        return label
    }()
    
    lazy var userTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var joinButton: UIButton = {
        let button = BaseButton.init()
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
    // Status of entering the room.
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        ToastComponents.shared.show(withMessage: "onRoomStateChanged uid: \(uid) state:\(state)")
    }
    

}

