/**
* Function name: BytePlusRTC sound mix
* Function brief description: If you need to play sound effects or music files during a call,
* And to make the sound heard by other members of the room, you need to use the mixing function.
* The mixing function can combine the audio data collected by the microphone with audio files, PCM audio data, etc. into one audio stream and publish it to the room.
* Reminder:
* 1. To demonstrate, all functional tokens are generated by the client side TokenGenerator class, please depend on the specific situation when actually accessing
* Reference document: https://docs.byteplus.com/en/docs/byteplus-rtc/docs-1178326
*/

import UIKit
import BytePlusRTC

class AudioEffectMixingViewController: BaseViewController, ByteRTCVideoDelegate, ByteRTCRoomDelegate,ByteRTCAudioEffectPlayerEventHandler {
    
    var rtcVideo: ByteRTCVideo?
    var rtcRoom1: ByteRTCRoom?
    var effectPlayer: ByteRTCAudioEffectPlayer?
    var effectId1: Int32!
    var effectId2: Int32!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.effectPlayer?.setEventHandler(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createUI()
        self.buildRTCEngine()
        self.buildEffectPlayer()
        self.buildActions()
    }
    
    deinit {
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
            generatorToken(roomId: roomId, userId: userId) { [weak self] token in
                self?.joinButton.setTitle(LocalizedString("button_leave_room"), for: .normal)
                
                // Join the room.
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
            self.joinButton.setTitle(LocalizedString("button_join_room"), for: .normal)
            self.rtcRoom1?.leaveRoom()
        }
    }
    
    func buildActions() {
        self.changePositionItem1.onValueChanged = {[weak self] value in
            if let intValue = Int32(value) {
                self?.effectPlayer?.setPosition(self?.effectId1 ?? 0, position: intValue)
            } else {
                print("Invalid value: \(value)")
            }
        }
        
        self.changeVolumeSlider1.onValueChanged = {[weak self] value in
            self?.effectPlayer?.setVolume(self?.effectId1 ?? 0, volume: Int32(value))
        }
        
        self.changePositionItem2.onValueChanged = {[weak self] value in
            if let intValue = Int32(value) {
                self?.effectPlayer?.setPosition(self?.effectId2 ?? 0, position: intValue)
            } else {
                print("Invalid value: \(value)")
            }
        }
        
        self.changeVolumeSlider2.onValueChanged = {[weak self] value in
            self?.effectPlayer?.setVolume(self?.effectId2 ?? 0, volume: Int32(value))
        }
  
        self.changeAllVolumeSlider.onValueChanged = {[weak self] value in
            self?.effectPlayer?.setVolumeAll(Int32(value))
        }
    }
    
    @objc func preloadFile()  {
        let filePath = Bundle.main.path(forResource: "rtc_audio", ofType: "aac")
        self.effectPlayer?.preload(self.effectId1, filePath: filePath)
    }
    
    @objc func unloadFile()  {
        self.effectPlayer?.unload(self.effectId1)
    }
    
    // Start playing sound effect 1
    @objc func startPlayEffect1()  {
        let filePath = Bundle.main.path(forResource: "rtc_audio", ofType: "aac")
        
        let config = ByteRTCAudioEffectPlayerConfig.init()
        config.type = .playoutAndPublish
        config.playCount = -1
        
        // Notice:
        // 1. If you need to play the same local file frequently, you can use preload to preload to avoid multiple applications for memory release.
        // 2. It is recommended not to call getDuration, getVolume and other get class interfaces immediately after start. Internally, start is executed asynchronously, and get is executed synchronously. Simultaneous calls cannot guarantee the order of execution.
        // The get interface should be executed after receiving the callback corresponding to start.
        let code = self.effectPlayer?.start(self.effectId1, filePath: filePath, config: config)
        print("start play effect1 code = \(code!)")
    }
    
    @objc func pausePlayEffect1()  {
        self.effectPlayer?.pause(self.effectId1)
    }
    
    @objc func resumePlayEffect1()  {
        self.effectPlayer?.resume(self.effectId1)
    }
    
    @objc func stopPlayEffect1()  {
        self.effectPlayer?.stop(self.effectId1)
    }
    
    // Start playing sound effect 2
    @objc func startPlayEffect2()  {
        let filePath = self.urlTextField.text
        
        let config = ByteRTCAudioEffectPlayerConfig.init()
        config.type = .playoutAndPublish
        config.playCount = 1
        
        let code = self.effectPlayer?.start(self.effectId2, filePath: filePath, config: config)
        print("start play effect2 code = \(code!)")
    }
    
    @objc func pausePlayEffect2()  {
        self.effectPlayer?.pause(self.effectId2)
    }
    
    @objc func resumePlayEffect2()  {
        self.effectPlayer?.resume(self.effectId2)
    }
    
    @objc func stopPlayEffect2()  {
        self.effectPlayer?.stop(self.effectId2)
    }
    
    @objc func pauseAllEffect()  {
        self.effectPlayer?.pauseAll()
    }
    
    @objc func resumeAllEffect()  {
        self.effectPlayer?.resumeAll()
    }
    
    @objc func stopAllEffect()  {
        self.effectPlayer?.stopAll()
    }
    
    @objc func scrollViewAction()  {
        self.view.endEditing(true)
    }
    
    func buildRTCEngine() {
        // Create engine
        self.rtcVideo = ByteRTCVideo.createRTCVideo(kAppID, delegate: self, parameters: [:])
        
        // Start local audio and video collection
        self.rtcVideo?.startVideoCapture()
        self.rtcVideo?.startAudioCapture()
        
        self.bindLocalRenderView()
    }
    
    // Get the sound effect player
    func buildEffectPlayer() {
        self.effectPlayer = self.rtcVideo?.getAudioEffectPlayer()
        
        weak var weakSelf = self
        self.effectPlayer?.setEventHandler(weakSelf)
        
        self.effectId1 = 1001
        self.effectId2 = 1002
    }
    
    func bindLocalRenderView() {
        // Set the local rendering view
        let canvas = ByteRTCVideoCanvas.init()
        canvas.view = self.localView.videoView
         canvas.renderMode = .hidden
        self.localView.userId = userTextField.text ?? ""
        
        self.rtcVideo?.setLocalVideoCanvas(.main, withCanvas: canvas);
    }
    
    func createUI() -> Void {
        // ScrollView
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        // Content view
        let view = UIView()
        scrollView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // Add UI
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(scrollView).multipliedBy(0.4)
        }
        
        containerView.addSubview(localView)
        localView.snp.makeConstraints { make in
            make.left.top.equalTo(self.containerView)
            make.width.height.equalTo(self.containerView)
        }
        
        view.addSubview(roomLabel)
        view.addSubview(roomTextField)
        view.addSubview(userLabel)
        view.addSubview(userTextField)
        view.addSubview(joinButton)
        
        roomLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(10)
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
            make.right.equalTo(self.view).offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(roomLabel.snp.bottom).offset(20)
            make.left.equalTo(roomLabel)
            make.right.equalTo(userTextField)
            make.height.equalTo(36)
        }
        
        view.addSubview(fileBackgroundView)
        fileBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(joinButton.snp.bottom).offset(20)
            make.left.right.equalTo(joinButton)
            make.height.equalTo(285)
        }
        
        fileBackgroundView.addSubview(fileTitleLabel)
        fileBackgroundView.addSubview(fileTextField)
        
        fileBackgroundView.addSubview(preloadButton)
        fileBackgroundView.addSubview(unloadButton)
        
        fileBackgroundView.addSubview(totalTimeLabel1)
        fileBackgroundView.addSubview(changePositionItem1)
        fileBackgroundView.addSubview(changeVolumeSlider1)

        fileBackgroundView.addSubview(startButton1)
        fileBackgroundView.addSubview(pauseButton1)
        fileBackgroundView.addSubview(resumeButton1)
        fileBackgroundView.addSubview(stopButton1)
        
        fileTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
        }
        
        fileTextField.snp.makeConstraints { make in
            make.top.equalTo(fileTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(fileTitleLabel)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        
        preloadButton.snp.makeConstraints { make in
            make.top.equalTo(fileTextField.snp.bottom).offset(10)
            make.left.equalTo(fileTextField)
            make.height.equalTo(30)
        }
        
        unloadButton.snp.makeConstraints { make in
            make.top.equalTo(preloadButton)
            make.left.equalTo(preloadButton.snp.right).offset(20)
            make.width.height.equalTo(preloadButton)
            make.right.equalTo(fileTextField)
        }
        
        totalTimeLabel1.snp.makeConstraints { make in
            make.top.equalTo(preloadButton.snp.bottom).offset(10)
            make.left.equalTo(preloadButton)
        }

        changePositionItem1.snp.makeConstraints { make in
            make.top.equalTo(totalTimeLabel1.snp.bottom).offset(20)
            make.left.equalTo(preloadButton)
        }

        changeVolumeSlider1.snp.makeConstraints { make in
            make.top.equalTo(changePositionItem1.snp.bottom).offset(20)
            make.left.equalTo(totalTimeLabel1)
            make.right.equalTo(unloadButton)
        }

        startButton1.snp.makeConstraints { make in
            make.top.equalTo(changeVolumeSlider1.snp.bottom).offset(20)
            make.left.equalTo(changeVolumeSlider1)
            make.height.equalTo(36)
        }

        pauseButton1.snp.makeConstraints { make in
            make.centerY.equalTo(startButton1)
            make.left.equalTo(startButton1.snp.right).offset(10)
            make.width.height.equalTo(startButton1)
        }

        resumeButton1.snp.makeConstraints { make in
            make.centerY.equalTo(startButton1)
            make.left.equalTo(pauseButton1.snp.right).offset(10)
            make.width.height.equalTo(startButton1)
        }

        stopButton1.snp.makeConstraints { make in
            make.centerY.equalTo(startButton1)
            make.left.equalTo(resumeButton1.snp.right).offset(10)
            make.width.equalTo(startButton1)
            make.right.height.equalTo(unloadButton)
        }
        
        view.addSubview(urlBackgroundView)
        
        urlBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(fileBackgroundView.snp.bottom).offset(20)
            make.left.right.equalTo(joinButton)
            make.height.equalTo(260)
        }

        urlBackgroundView.addSubview(urlTitleLabel)
        urlBackgroundView.addSubview(urlTextField)
        urlBackgroundView.addSubview(totalTimeLabel2)
        urlBackgroundView.addSubview(changePositionItem2)
        urlBackgroundView.addSubview(changeVolumeSlider2)
        
        urlBackgroundView.addSubview(startButton2)
        urlBackgroundView.addSubview(pauseButton2)
        urlBackgroundView.addSubview(resumeButton2)
        urlBackgroundView.addSubview(stopButton2)
        
        urlTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.top.equalTo(urlTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(urlTitleLabel)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }

        totalTimeLabel2.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(10)
            make.left.equalTo(urlTextField)
        }

        changePositionItem2.snp.makeConstraints { make in
            make.top.equalTo(totalTimeLabel2.snp.bottom).offset(20)
            make.left.equalTo(urlTextField)
        }
        
        changeVolumeSlider2.snp.makeConstraints { make in
            make.top.equalTo(changePositionItem2.snp.bottom).offset(20)
            make.left.equalTo(changePositionItem2)
            make.right.equalTo(urlTextField)
        }

        startButton2.snp.makeConstraints { make in
            make.top.equalTo(changeVolumeSlider2.snp.bottom).offset(20)
            make.left.equalTo(changeVolumeSlider2)
            make.height.equalTo(36)
        }

        pauseButton2.snp.makeConstraints { make in
            make.centerY.equalTo(startButton2)
            make.left.equalTo(startButton2.snp.right).offset(10)
            make.width.height.equalTo(startButton2)
        }

        resumeButton2.snp.makeConstraints { make in
            make.centerY.equalTo(startButton2)
            make.left.equalTo(pauseButton2.snp.right).offset(10)
            make.width.height.equalTo(startButton2)
        }

        stopButton2.snp.makeConstraints { make in
            make.centerY.equalTo(startButton2)
            make.left.equalTo(resumeButton2.snp.right).offset(10)
            make.width.height.equalTo(startButton2)
            make.right.equalTo(changeVolumeSlider2)
        }
        
        view.addSubview(changeAllVolumeSlider)
        
        view.addSubview(pauseAllButton)
        view.addSubview(resumeAllButton)
        view.addSubview(stopAllButton)

        changeAllVolumeSlider.snp.makeConstraints { make in
            make.top.equalTo(urlBackgroundView.snp.bottom).offset(20)
            make.left.right.equalTo(urlBackgroundView)
        }

        pauseAllButton.snp.makeConstraints { make in
            make.top.equalTo(changeAllVolumeSlider.snp.bottom).offset(10)
            make.left.equalTo(changeAllVolumeSlider)
            make.height.equalTo(36)
        }

        resumeAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(pauseAllButton)
            make.left.equalTo(pauseAllButton.snp.right).offset(10)
            make.width.height.equalTo(pauseAllButton)
        }

        stopAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(pauseAllButton)
            make.left.equalTo(resumeAllButton.snp.right).offset(10)
            make.right.equalTo(changeAllVolumeSlider)
            make.width.height.equalTo(pauseAllButton)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    // MARK: Lazy laod
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewAction))
        scrollView.addGestureRecognizer(tap)
        
        return scrollView
    }()
    
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
    
    lazy var fileBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 252/255.0, green: 253/255.0, blue: 254/255.0, alpha: 1.0)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 234/255.0, green: 237/255.0, blue: 241/255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var fileTitleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString("label_mixing_file_title")
        return label
    }()
    
    lazy var fileTextField: TextFieldView = {
        let textField = TextFieldView()
        textField.title = LocalizedString("label_mixing_file_label")
        textField.text = "rtc_audio.aac"
        return textField
    }()
    
    lazy var preloadButton: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_preload"), for: .normal)
        button.addTarget(self, action: #selector(preloadFile), for: .touchUpInside)
        return button
    }()
    
    lazy var unloadButton: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_unload"), for: .normal)
        button.addTarget(self, action: #selector(unloadFile), for: .touchUpInside)
        return button
    }()
    
    lazy var totalTimeLabel1: UILabel = {
        let label = UILabel()
        label.text = "\(LocalizedString("label_total_time_length")): -ms"
        return label
    }()
    
    lazy var changePositionItem1: SettingItemView = {
        let settingView = SettingItemView()
        settingView.title = LocalizedString("button_jump_time")
        return settingView
    }()
    
    lazy var changeVolumeSlider1: SliderView = {
        let sliderView = SliderView.init(minValue: 0, maxValue: 400, defaultValue: 100)
        sliderView.title = LocalizedString("label_volume")
        return sliderView
    }()
    
    lazy var startButton1: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_start"), for: .normal)
        button.addTarget(self, action: #selector(startPlayEffect1), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseButton1: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_pause"), for: .normal)
        button.addTarget(self, action: #selector(pausePlayEffect1), for: .touchUpInside)
        return button
    }()
    
    lazy var resumeButton1: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_resume"), for: .normal)
        button.addTarget(self, action: #selector(resumePlayEffect1), for: .touchUpInside)
        return button
    }()
    
    lazy var stopButton1: UIButton = {
        let button = BaseButton.init()
        button.setTitle(LocalizedString("button_stop"), for: .normal)
        button.addTarget(self, action: #selector(stopPlayEffect1), for: .touchUpInside)
        return button
    }()
    
    lazy var urlBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 252/255.0, green: 253/255.0, blue: 254/255.0, alpha: 1.0)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 234/255.0, green: 237/255.0, blue: 241/255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var urlTitleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedString("label_mixing_url_title")
        return label
    }()
    
    lazy var urlTextField: TextFieldView = {
        let textField = TextFieldView()
        textField.title = LocalizedString("label_mixing_url_label")
        textField.text = kOnLineAudioUrl
        return textField
    }()
    
    lazy var totalTimeLabel2: UILabel = {
        let label = UILabel()
        label.text = "\(LocalizedString("label_total_time_length")): -ms"
        return label
    }()
    
    lazy var changePositionItem2: SettingItemView = {
        let settingView = SettingItemView()
        settingView.title = LocalizedString("button_jump_time")
        return settingView
    }()
    
    lazy var changeVolumeSlider2: SliderView = {
        let sliderView = SliderView.init(minValue: 0, maxValue: 400, defaultValue: 100)
        sliderView.title = LocalizedString("label_volume")
        return sliderView
    }()
    
    lazy var startButton2: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_start"), for: .normal)
        button.addTarget(self, action: #selector(startPlayEffect2), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseButton2: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_pause"), for: .normal)
        button.addTarget(self, action: #selector(pausePlayEffect2), for: .touchUpInside)
        return button
    }()
    
    lazy var resumeButton2: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_resume"), for: .normal)
        button.addTarget(self, action: #selector(resumePlayEffect2), for: .touchUpInside)
        return button
    }()
    
    lazy var stopButton2: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_stop"), for: .normal)
        button.addTarget(self, action: #selector(stopPlayEffect2), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseAllButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_pause_all"), for: .normal)
        button.addTarget(self, action: #selector(pauseAllEffect), for: .touchUpInside)
        return button
    }()
    
    lazy var resumeAllButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_resume_all"), for: .normal)
        button.addTarget(self, action: #selector(resumeAllEffect), for: .touchUpInside)
        return button
    }()
    
    lazy var stopAllButton: UIButton = {
        let button = BaseButton()
        button.setTitle(LocalizedString("button_stop_all"), for: .normal)
        button.addTarget(self, action: #selector(stopAllEffect), for: .touchUpInside)
        return button
    }()
    
    lazy var changeAllVolumeSlider: SliderView = {
        let sliderView = SliderView.init(minValue: 0, maxValue: 400, defaultValue: 100)
        sliderView.title = LocalizedString("label_all_effect_volume")
        return sliderView
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
    
    // MARK: ByteRTCVideoDelegate & ByteRTCRoomDelegate
    // Room entry status
    func rtcRoom(_ rtcRoom: ByteRTCRoom, onRoomStateChanged roomId: String, withUid uid: String, state: Int, extraInfo: String) {
        ToastComponents.shared.show(withMessage: "onRoomStateChanged uid: \(uid) state:\(state)")
        
    }
    
    // MARK: ByteRTCAudioEffectPlayerEventHandler
    // Sound effect playback status
    func onAudioEffectPlayerStateChanged(_ effectId: Int32, state: ByteRTCPlayerState, error: ByteRTCPlayerError) {
        
        ToastComponents.shared.show(withMessage: "onAudioEffectPlayerStateChanged effectId: \(effectId) state:\(state.rawValue) error:\(error.rawValue)")
        
        DispatchQueue.main.async
        {
            if effectId == self.effectId1 {
                
                if state == .playing {
                    
                    let totalTime = self.effectPlayer?.getDuration(self.effectId1!)
                    self.totalTimeLabel1.text = "\(LocalizedString("label_total_time_length")): \(totalTime ?? 0)ms"
                }
                
            } else {
                
                if state == .playing {
                    let totalTime = self.effectPlayer?.getDuration(self.effectId2!)
                    self.totalTimeLabel2.text = "\(LocalizedString("label_total_time_length")): \(totalTime ?? 0)ms"
                }
            }
        }
    }
}