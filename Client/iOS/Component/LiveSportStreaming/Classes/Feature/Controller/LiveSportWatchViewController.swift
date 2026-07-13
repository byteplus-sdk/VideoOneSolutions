// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit
import ToolKit

/// Live watch page wiring TTSDK player, channel switching and chat interaction.
public final class LiveSportWatchViewController: UIViewController {

    /// Entry point that drives the page presentation.
    public enum EntryMode {
        /// Home entry: full-featured watch page (unchanged behavior).
        case full
        /// Live-experience entry: simplified page (no multi-camera, top close
        /// button only, video layout adapts to the stream aspect ratio).
        case experience
    }

    // MARK: - State

    private let entryMode: EntryMode

    private var channels: [LiveStreamChannel] = []
    private var currentChannel: LiveStreamChannel?
    private var isFollowed: Bool = false
    private var isCameraPanelExpanded: Bool = true
    private var isPlaying: Bool = true
    private var isLandscapeMode: Bool = false
    private var isControlsHidden: Bool = false
    private var isLocked: Bool = false
    private var isKeyboardVisible: Bool = false
    private var isPortraitVideo: Bool = false
    private var isLikeModeActive: Bool = false
    private var likeComboCount: Int = 0
    private var likeModeIdleWorkItem: DispatchWorkItem?
    private let likeModeIdleWindow: TimeInterval = 0.5
    private var currentQuality: LiveSportStreamURL.WatchQualityOption = .quality1080
    private var activeSidePanel: SidePanelKind = .none
    private var messages: [LiveChatMessage] = []
    private var currentSetting: LiveSetting = LiveSportSettingManager.shared.currentSetting

    private enum SidePanelKind {
        case none
        case camera
        case quality
        case setting
        case gift
    }

    private let player: LiveSportPlayerManagerProtocol = LiveSportPlayerManager()

    public init(mode: EntryMode = .full) {
        self.entryMode = mode
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subviews

    private let backgroundView = UIImageView()
    private let playerHostView = LivePlayerControlView()
    private let likeEmitterView = LiveSportLikeEmitter()
    private let topInfoView = LiveSportWatchTopInfoView()
    private let cameraSwitcherView = LiveSportCameraSwitcherView()
    private let chatOverlayView = LiveSportWatchChatView()
    private let inputBarView = LiveSportWatchInputBarView()
    private let landscapeControlsView = LiveSportWatchLandscapeControlsView()
    private let sidePanelContainer = LiveSportLandscapeSidePanelContainer()
    private let cameraPanelView = LiveSportLandscapeCameraPanelView()
    private let qualityPanelView = LiveSportLandscapeQualityPanelView()
    private let landscapeSettingView = LiveSportWatchSettingSheetView()
    private let landscapeExperienceSettingView = LiveSportExperienceSettingSheetView()
    private let giftBannerStack = LiveSportGiftBannerStack()
    private let giftContentView = LiveSportGiftContentView()
    private var giftPanel: LiveSportGiftPanel?
    private var cameraSwitcherHeightConstraint: Constraint?
    private var inputBarBottomConstraint: Constraint?
    private var playerHostPortraitConstraints: [Constraint] = []
    private var playerHostLandscapeConstraints: [Constraint] = []
    private var playerHostFullscreenConstraints: [Constraint] = []
    private var chatOverlayCardTopConstraint: Constraint?
    private var chatOverlayFullscreenTopConstraint: Constraint?
    private var giftBannerPortraitConstraints: [Constraint] = []
    private var giftBannerLandscapeConstraints: [Constraint] = []

    /// Height of the landscape bottom control bar (`LiveSportWatchLandscapeControlsView.bottomBar`),
    /// used to pin the gift banner stack 10pt above it.
    private let landscapeBottomBarHeight: CGFloat = 80

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 6.0 / 255.0, green: 18.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
        currentSetting = LiveSportSettingManager.shared.currentSetting
        if entryMode == .experience,
           let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: currentSetting) {
            currentSetting = resolvedSetting
            LiveSportSettingManager.shared.update(setting: resolvedSetting)
        }
        setupSubviews()
        bindActions()
        observeKeyboardNotifications()
        loadChannels()
        applyPlayerSettingToggles(currentSetting)
        seedSampleMessages()
        applyEntryModeAppearance()
        if let defaultChannel = channels.first(where: { $0.id == "camera_b" }) ?? channels.first {
            switchTo(channel: defaultChannel)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            player.stop()
            if isLandscapeMode {
                setDeviceInterfaceOrientation(.portrait)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupSubviews() {
        view.addSubview(backgroundView)
        backgroundView.image = LiveSportImage(named: "sport_watcher_bg")
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.clipsToBounds = true
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(playerHostView)
        view.addSubview(topInfoView)
        view.addSubview(cameraSwitcherView)
        view.addSubview(chatOverlayView)
        view.addSubview(inputBarView)
        view.addSubview(landscapeControlsView)
        view.addSubview(sidePanelContainer)

//        playerHostView.layer.contents = LiveSportImage(named: "live_sport_watch_player_bg")?.cgImage
//        playerHostView.layer.contentsGravity = .resizeAspectFill
        playerHostView.clipsToBounds = true
        player.renderView.backgroundColor = .clear

        playerHostView.snp.makeConstraints { make in
            self.playerHostPortraitConstraints = [
                make.top.equalToSuperview().offset(120).constraint,
                make.leading.trailing.equalToSuperview().constraint,
                make.height.equalTo(view.snp.width).multipliedBy(9.0 / 16.0).constraint
            ]
        }
        playerHostView.snp.prepareConstraints { make in
            self.playerHostLandscapeConstraints = [
                make.edges.equalToSuperview().constraint
            ]
        }
        playerHostView.snp.prepareConstraints { make in
            self.playerHostFullscreenConstraints = [
                make.edges.equalToSuperview().constraint
            ]
        }
        playerHostView.attach(renderView: player.renderView)
        playerHostView.onDoubleTap = { [weak self] point in
            self?.handlePlayerDoubleTap(at: point)
        }
        playerHostView.onSingleTap = { [weak self] point in
            self?.handlePlayerSingleTap(at: point)
        }
        playerHostView.onLeftControlTap = { [weak self] in
            self?.handlePlayControlTap()
        }
        playerHostView.onRightControlTap = { [weak self] in
            self?.handleRotateControlTap()
        }

        topInfoView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(96)
        }

        cameraSwitcherView.snp.makeConstraints { make in
            make.top.equalTo(playerHostView.snp.bottom).offset(-1)
            make.leading.trailing.equalToSuperview()
            self.cameraSwitcherHeightConstraint = make.height.equalTo(121).constraint
        }

        chatOverlayView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            self.chatOverlayCardTopConstraint = make.top.equalTo(cameraSwitcherView.snp.bottom).offset(8).constraint
            make.trailing.equalToSuperview().offset(-80)
            make.bottom.equalTo(inputBarView.snp.top).offset(-12)
        }
        chatOverlayView.snp.prepareConstraints { make in
            self.chatOverlayFullscreenTopConstraint = make.top.equalTo(playerHostView.safeAreaLayoutGuide.snp.bottom).offset(8).constraint
        }

        inputBarView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(12)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-12)
            self.inputBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
            make.height.equalTo(36)
        }

        landscapeControlsView.isHidden = true
        landscapeControlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sidePanelContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(likeEmitterView)
        likeEmitterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(giftBannerStack)
        giftBannerStack.snp.makeConstraints { make in
            make.width.equalTo(202)
            make.height.equalTo(90)
        }
        giftBannerStack.snp.prepareConstraints { make in
            self.giftBannerPortraitConstraints = [
                make.leading.equalTo(chatOverlayView.snp.leading).constraint,
                make.top.equalTo(chatOverlayView.snp.top).constraint
            ]
        }
        giftBannerStack.snp.prepareConstraints { make in
            self.giftBannerLandscapeConstraints = [
                make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(12).constraint,
                make.bottom.equalTo(view.snp.bottom).offset(-(landscapeBottomBarHeight + 10)).constraint
            ]
        }
        giftBannerPortraitConstraints.forEach { $0.activate() }

        setupKeyboardDismissGesture()
        setupLandscapeWiring()
        updatePlayerActionButtons()
    }

    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboardTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc
    private func handleDismissKeyboardTap() {
        inputBarView.dismissInput()
        view.endEditing(true)
    }

    private func setupLandscapeWiring() {
        landscapeControlsView.onBackTap = { [weak self] in
            self?.handleLandscapeBackTap()
        }
        landscapeControlsView.onFollowTap = { [weak self] in
            self?.handleFollowTap()
        }
        landscapeControlsView.onSettingsTap = { [weak self] in
            self?.presentWatchSettingSheet()
        }
        landscapeControlsView.onLockTap = { [weak self] in
            self?.handleLockTap()
        }
        landscapeControlsView.onPlayPauseTap = { [weak self] in
            self?.handlePlayControlTap()
        }
        landscapeControlsView.onGiftTap = { [weak self] in
            self?.presentGiftPanel()
        }
        landscapeControlsView.onMultiCameraTap = { [weak self] in
            self?.presentCameraPanel()
        }
        landscapeControlsView.onQualityTap = { [weak self] in
            self?.presentQualityPanel()
        }
        landscapeControlsView.onInputTap = { [weak self] in
            guard let self = self else { return }
            self.inputBarView.isHidden = false
            self.view.bringSubviewToFront(self.inputBarView)
            self.inputBarView.focusInput()
        }
        landscapeControlsView.onAutoHide = { [weak self] in
            self?.isControlsHidden = true
        }

        cameraPanelView.onSelectChannel = { [weak self] channel in
            self?.switchTo(channel: channel)
            self?.refreshLandscapeCameraPanel()
        }
        qualityPanelView.onSelectQuality = { [weak self] quality in
            guard let self = self else { return }
            self.currentQuality = quality
            self.landscapeControlsView.updateQuality(text: quality.displayTitle)
            self.applyCurrentPlaybackRoute()
            self.dismissSidePanel(animated: true)
        }

        sidePanelContainer.onDismiss = { [weak self] in
            self?.dismissSidePanel(animated: true)
        }

        giftContentView.onSend = { [weak self] gift in
            guard let self = self else { return }
            self.showGiftBanner(for: gift)
        }

        landscapeSettingView.applyLandscapeSidePanelStyle()
        landscapeSettingView.onClose = { [weak self] in
            self?.dismissSidePanel(animated: true)
        }
        landscapeSettingView.onSave = { [weak self] setting in
            self?.apply(setting: setting)
            self?.dismissSidePanel(animated: true)
        }

        landscapeExperienceSettingView.applyLandscapeSidePanelStyle()
        landscapeExperienceSettingView.onClose = { [weak self] in
            self?.dismissSidePanel(animated: true)
        }
        landscapeExperienceSettingView.onSave = { [weak self] setting in
            self?.apply(setting: setting)
            self?.dismissSidePanel(animated: true)
        }
    }

    // MARK: - Data

    private func loadChannels() {
        channels = [
            LiveStreamChannel(id: LiveStreamChannel.cameraA,
                              title: LiveSportL10n("live_sport_channel_a"),
                              streamURL: LiveSportStreamURL.channelA,
                              streamProtocol: .flvLowLatency,
                              anchorName: LiveSportL10n("live_sport_anchor_name"),
                              audienceCount: 386000),
            LiveStreamChannel(id: LiveStreamChannel.cameraB,
                              title: LiveSportL10n("live_sport_channel_b"),
                              streamURL: LiveSportStreamURL.channelB,
                              streamProtocol: .flvLowLatency,
                              anchorName: LiveSportL10n("live_sport_anchor_name"),
                              audienceCount: 386000),
            LiveStreamChannel(id: LiveStreamChannel.cameraC,
                              title: LiveSportL10n("live_sport_channel_c"),
                              streamURL: LiveSportStreamURL.channelC,
                              streamProtocol: .flvLowLatency,
                              anchorName: LiveSportL10n("live_sport_anchor_name"),
                              audienceCount: 386000),
            LiveStreamChannel(id: LiveStreamChannel.cameraD,
                              title: LiveSportL10n("live_sport_channel_d"),
                              streamURL: LiveSportStreamURL.channelD,
                              streamProtocol: .flvLowLatency,
                              anchorName: LiveSportL10n("live_sport_anchor_name"),
                              audienceCount: 386000)
        ]
    }

    private func seedSampleMessages() {
        let user1 = LiveSportL10n("live_sport_sample_user_1")
        let user2 = LiveSportL10n("live_sport_sample_user_2")
        let user3 = LiveSportL10n("live_sport_sample_user_3")
        let user4 = LiveSportL10n("live_sport_sample_user_4")
        let msg1 = LiveSportL10n("live_sport_sample_message_1")
        let msg2 = LiveSportL10n("live_sport_sample_message_2")
        let msg3 = LiveSportL10n("live_sport_sample_message_3")
        let msg4 = LiveSportL10n("live_sport_sample_message_4")
        messages = [
            LiveChatMessage(userName: user1, userLevel: 1, content: msg1),
            LiveChatMessage(userName: user2, userLevel: 2, content: msg2),
            LiveChatMessage(userName: user3, userLevel: 3, content: msg3),
            LiveChatMessage(userName: user2, userLevel: 2, content: msg2),
            LiveChatMessage(userName: user1, userLevel: 1, content: msg1),
            LiveChatMessage(userName: user2, userLevel: 2, content: msg2),
            LiveChatMessage(userName: user3, userLevel: 3, content: msg3),
            LiveChatMessage(userName: user4, userLevel: 1, content: msg4),
            LiveChatMessage(userName: user3, userLevel: 3, content: msg3),
            LiveChatMessage(userName: user3, userLevel: 3, content: msg3)
        ]
        chatOverlayView.reload(messages: messages)
    }

    private func switchTo(channel: LiveStreamChannel) {
        currentChannel = channel
        isPlaying = true
        topInfoView.configure(anchorName: channel.anchorName,
                              statusText: LiveSportL10n("live_sport_watch_host_status"),
                              avatarURL: channel.anchorAvatarURL,
                              avatarImage: LiveSportImage(named: "live_sport_watch_anchor_avatar"),
                              isFollowed: isFollowed)
        applyCurrentPlaybackRoute()
        updatePlayerActionButtons()
        refreshCameraSwitcher()
    }

    private func bindActions() {
        topInfoView.onFollowTap = { [weak self] in
            self?.handleFollowTap()
        }
        topInfoView.onCloseTap = { [weak self] in
            self?.closePage()
        }
        cameraSwitcherView.onToggleExpanded = { [weak self] in
            self?.toggleCameraPanel()
        }
        cameraSwitcherView.onSelectChannel = { [weak self] channel in
            self?.switchTo(channel: channel)
        }
        inputBarView.onSubmitText = { [weak self] text in
            self?.handleSubmit(text: text)
        }
        inputBarView.onGiftTap = { [weak self] in
            self?.presentGiftPanel()
        }
        inputBarView.onMoreTap = { [weak self] in
            self?.presentWatchSettingSheet()
        }
    }

    private func updatePlayerActionButtons() {
        let playImageName = isPlaying ? "sport_video_pause" : "sport_video_play"
        playerHostView.setLeftControlImage(LiveSportImage(named: playImageName))
        playerHostView.setRightControlImage(LiveSportImage(named: "sport_rotate"))
    }

    private func refreshCameraSwitcher() {
        guard entryMode != .experience else { return }
        let items = channels.map { channel in
            LiveSportCameraSwitcherView.Item(channel: channel, image: cameraCoverImage(for: channel.id))
        }
        cameraSwitcherView.configure(items: items,
                                     selectedId: currentChannel?.id,
                                     isPlaying: isPlaying,
                                     isExpanded: isCameraPanelExpanded)
        cameraSwitcherHeightConstraint?.update(offset: cameraSwitcherView.preferredHeight)
    }

    private func cameraCoverImage(for channelId: String) -> UIImage? {
        let assetName: String
        switch channelId {
        case "camera_a":
            assetName = "live_sport_camera_a"
        case "camera_b":
            assetName = "live_sport_camera_b"
        case "camera_c":
            assetName = "live_sport_camera_c"
        case "camera_d":
            assetName = "live_sport_camera_d"
        default:
            return nil
        }
        return LiveSportImage(named: assetName)
    }

    private func handleFollowTap() {
        isFollowed.toggle()
        topInfoView.updateFollowState(isFollowed: isFollowed)
        landscapeControlsView.updateFollow(isFollowed: isFollowed)
    }

    private func handlePlayControlTap() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updatePlayerActionButtons()
        landscapeControlsView.updatePlayPause(isPlaying: isPlaying)
        refreshCameraSwitcher()
        refreshLandscapeCameraPanel()
    }

    private func handleRotateControlTap() {
        let goLandscape = !isLandscapeMode
        setDeviceInterfaceOrientation(goLandscape ? .landscapeRight : .portrait)
    }

    private func handleLandscapeBackTap() {
        if activeSidePanel != .none {
            dismissSidePanel(animated: true)
            return
        }
        if isLocked {
            isLocked = false
            landscapeControlsView.setLocked(false, animated: false)
        }
        setDeviceInterfaceOrientation(.portrait)
    }

    private func handleLockTap() {
        isLocked.toggle()
        landscapeControlsView.setLocked(isLocked, animated: true)
        if isLocked {
            dismissSidePanel(animated: true)
        }
    }

    private func handlePlayerSingleTap() {
        guard isLandscapeMode else { return }
        if isKeyboardVisible || inputBarView.isInputEditing {
            handleDismissKeyboardTap()
            return
        }
        if activeSidePanel != .none {
            dismissSidePanel(animated: true)
            return
        }
        if isLocked {
            landscapeControlsView.toggleLockedControls(animated: true)
            return
        }
        if isControlsHidden {
            isControlsHidden = false
            landscapeControlsView.showThenAutoHide(animated: true)
        } else {
            isControlsHidden = true
            landscapeControlsView.setControlsHidden(true, animated: true)
        }
    }

    // MARK: - Like Effects

    /// Double tap always enters like-mode (portrait and landscape) and emits the
    /// first like; it never toggles the landscape controls bar.
    private func handlePlayerDoubleTap(at point: CGPoint) {
        isLikeModeActive = true
        emitLike(at: point)
    }

    /// While like-mode is active, a single tap only emits a like and suppresses
    /// the landscape controls toggle. Otherwise it falls through to the normal
    /// single-tap behavior.
    private func handlePlayerSingleTap(at point: CGPoint) {
        if isLikeModeActive {
            emitLike(at: point)
            return
        }
        handlePlayerSingleTap()
    }

    private func emitLike(at point: CGPoint) {
        let icon = LiveSportImage(named: "like_icon_\(Int.random(in: 1...7))")
        let burstPoint = likeEmitterView.convert(point, from: playerHostView)
        likeEmitterView.emitBurst(icon: icon, at: burstPoint)
        likeEmitterView.emitFloat(icon: icon)

        likeComboCount += 1
        likeEmitterView.updateCombo(count: likeComboCount, at: burstPoint)

        restartLikeModeIdleTimer()
    }

    private func restartLikeModeIdleTimer() {
        likeModeIdleWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.exitLikeMode()
        }
        likeModeIdleWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + likeModeIdleWindow, execute: workItem)
    }

    private func exitLikeMode() {
        isLikeModeActive = false
        likeModeIdleWorkItem?.cancel()
        likeModeIdleWorkItem = nil
        likeComboCount = 0
    }

    // MARK: - Landscape Layout

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        exitLikeMode()
        likeEmitterView.resetCombo()
        giftPanel?.dismiss(animated: false)
        giftPanel = nil
        giftBannerStack.clear()
        let landscape = size.width > size.height
        coordinator.animate(alongsideTransition: { _ in
            self.applyLayout(isLandscape: landscape)
        })
    }

    private func applyLayout(isLandscape: Bool) {
        isLandscapeMode = isLandscape
        view.endEditing(true)
        isKeyboardVisible = false
        inputBarBottomConstraint?.update(offset: 0)
        if isLandscape {
            giftBannerPortraitConstraints.forEach { $0.deactivate() }
            giftBannerLandscapeConstraints.forEach { $0.activate() }
            playerHostPortraitConstraints.forEach { $0.deactivate() }
            playerHostFullscreenConstraints.forEach { $0.deactivate() }
            playerHostLandscapeConstraints.forEach { $0.activate() }
            topInfoView.isHidden = true
            cameraSwitcherView.isHidden = true
            chatOverlayView.isHidden = true
            inputBarView.isHidden = true
            playerHostView.setControlButtonsHidden(true)
            landscapeControlsView.isHidden = false
            isControlsHidden = false
            landscapeControlsView.showThenAutoHide(animated: false)
            landscapeControlsView.setLocked(isLocked, animated: false)
            landscapeControlsView.setMode(showMultiCamera: entryMode != .experience,
                                          showQuality: entryMode != .experience)
            landscapeControlsView.configure(anchorName: currentChannel?.anchorName ?? "",
                                            isFollowed: isFollowed,
                                            isPlaying: isPlaying,
                                            qualityText: currentQuality.displayTitle)
        } else {
            giftBannerLandscapeConstraints.forEach { $0.deactivate() }
            giftBannerPortraitConstraints.forEach { $0.activate() }
            giftBannerStack.direction = .topDown
            playerHostLandscapeConstraints.forEach { $0.deactivate() }
            activatePortraitPlayerConstraints()
            topInfoView.isHidden = false
            cameraSwitcherView.isHidden = entryMode == .experience
            chatOverlayView.isHidden = false
            inputBarView.isHidden = false
            inputBarView.setAccessoryButtonsHidden(false, animated: false)
            playerHostView.setControlButtonsHidden(false)
            landscapeControlsView.isHidden = true
            landscapeControlsView.cancelAutoHide()
            landscapeControlsView.setMode(showMultiCamera: true, showQuality: true)
            isLocked = false
            dismissSidePanel(animated: false)
        }
        chatOverlayView.reload(messages: messages)
        view.layoutIfNeeded()
    }

    private func activatePortraitPlayerConstraints() {
        if entryMode == .experience, isPortraitVideo {
            playerHostPortraitConstraints.forEach { $0.deactivate() }
            playerHostFullscreenConstraints.forEach { $0.activate() }
        } else {
            playerHostFullscreenConstraints.forEach { $0.deactivate() }
            playerHostPortraitConstraints.forEach { $0.activate() }
        }
    }

    // MARK: - Entry Mode

    private func applyEntryModeAppearance() {
        guard entryMode == .experience else { return }
        cameraSwitcherView.isHidden = true
        cameraSwitcherHeightConstraint?.update(offset: 0)
        topInfoView.setInfoHidden(true)
        chatOverlayCardTopConstraint?.deactivate()
        chatOverlayFullscreenTopConstraint?.activate()
        view.bringSubviewToFront(topInfoView)
        player.onVideoSizeChanged = { [weak self] size in
            self?.handleVideoSizeChanged(size)
        }
    }

    private func handleVideoSizeChanged(_ size: CGSize) {
        guard entryMode == .experience, !isLandscapeMode else { return }
        let portraitVideo = size.height >= size.width && size.width > 0
        guard portraitVideo != isPortraitVideo else { return }
        isPortraitVideo = portraitVideo

        if portraitVideo {
            playerHostPortraitConstraints.forEach { $0.deactivate() }
            playerHostFullscreenConstraints.forEach { $0.activate() }
            player.setRenderFillMode(aspectFill: true)
        } else {
            playerHostFullscreenConstraints.forEach { $0.deactivate() }
            playerHostPortraitConstraints.forEach { $0.activate() }
            player.setRenderFillMode(aspectFill: false)
        }
        view.bringSubviewToFront(topInfoView)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Side Panels

    private func presentCameraPanel() {
        refreshLandscapeCameraPanel()
        activeSidePanel = .camera
        sidePanelContainer.show(content: cameraPanelView, width: LiveSportLandscapeCameraPanelView.preferredWidth)
    }

    private func presentQualityPanel() {
        qualityPanelView.configure(options: LiveSportStreamURL.watchQualityOptions,
                                   selectedQuality: currentQuality)
        activeSidePanel = .quality
        sidePanelContainer.show(content: qualityPanelView, width: LiveSportLandscapeQualityPanelView.preferredWidth)
    }

    private func presentLandscapeSettingPanel() {
        landscapeSettingView.configure(setting: currentSetting)
        activeSidePanel = .setting
        sidePanelContainer.show(content: landscapeSettingView, width: 320)
    }

    private func presentLandscapeExperienceSettingPanel() {
        landscapeExperienceSettingView.configure(setting: currentSetting)
        activeSidePanel = .setting
        sidePanelContainer.show(content: landscapeExperienceSettingView, width: 320)
    }

    private func dismissSidePanel(animated: Bool) {
        guard activeSidePanel != .none else { return }
        activeSidePanel = .none
        sidePanelContainer.hide(animated: animated)
    }

    private func refreshLandscapeCameraPanel() {
        let items = channels.map { channel in
            LiveSportLandscapeCameraPanelView.Item(channel: channel, image: cameraCoverImage(for: channel.id))
        }
        cameraPanelView.configure(items: items, selectedId: currentChannel?.id, isPlaying: isPlaying)
    }

    private func toggleCameraPanel() {
        isCameraPanelExpanded.toggle()
        cameraSwitcherHeightConstraint?.update(offset: isCameraPanelExpanded ? 121 : 41)
        cameraSwitcherView.setExpanded(isCameraPanelExpanded, animated: true)
        UIView.animate(withDuration: 0.28,
                       delay: 0,
                       usingSpringWithDamping: 0.92,
                       initialSpringVelocity: 0.15,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.view.layoutIfNeeded()
        }
    }

    private func appendChatMessage(_ message: LiveChatMessage) {
        messages.append(message)
        chatOverlayView.append(message: message)
    }

    private func handleSubmit(text: String) {
        let randomLevel = Int.random(in: 1...3)
        appendChatMessage(LiveChatMessage(userName: LiveSportL10n("live_sport_watch_self_name"), userLevel: randomLevel, content: text))
    }

    // MARK: - Gift Panel & Banner

    private func presentGiftPanel() {
        if isLandscapeMode {
            activeSidePanel = .gift
            sidePanelContainer.show(content: giftContentView, width: 320)
        } else {
            let panel = LiveSportGiftPanel()
            panel.onSend = { [weak self] gift in
                guard let self = self else { return }
                self.showGiftBanner(for: gift)
            }
            panel.onDismiss = { [weak self] in
                self?.giftPanel?.dismiss(animated: true)
                self?.giftPanel = nil
            }
            giftPanel = panel
            panel.present(in: view)
        }
    }

    private func showGiftBanner(for gift: LiveSportGift) {
        let avatar = LiveSportImage(named: "like_icon_\(Int.random(in: 1...7))")
        giftBannerStack.show(senderName: LiveSportL10n("live_sport_watch_self_name"),
                             gift: gift,
                             avatar: avatar)
    }

    private func presentWatchSettingSheet() {
        if isLandscapeMode {
            if entryMode == .experience {
                presentLandscapeExperienceSettingPanel()
            } else {
                presentLandscapeSettingPanel()
            }
            return
        }

        if entryMode == .experience {
            let controller = LiveSportExperienceSettingSheetViewController(setting: currentSetting)
            controller.onSave = { [weak self] setting in
                self?.apply(setting: setting)
            }
            present(controller, animated: false)
            return
        }
        let controller = LiveSportWatchSettingSheetViewController(setting: currentSetting)
        controller.onSave = { [weak self] setting in
            self?.apply(setting: setting)
        }
        present(controller, animated: false)
    }

    private func apply(setting: LiveSetting) {
        if entryMode == .experience {
            guard let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: setting) else {
                return
            }
            LiveSportSettingManager.shared.update(setting: resolvedSetting)
        } else {
            LiveSportSettingManager.shared.update(setting: setting)
        }
        currentSetting = LiveSportSettingManager.shared.currentSetting
        if currentSetting.enableABR {
            currentQuality = .qualityDefault
        }
        applyPlayerSettingToggles(currentSetting)
        applyCurrentPlaybackRoute()
        updatePlayerActionButtons()
        refreshCameraSwitcher()
    }

    private func applyPlayerSettingToggles(_ setting: LiveSetting) {
        player.setABR(enabled: setting.enableABR)
        player.setSuperResolution(enabled: setting.enableSuperResolution)
        player.setSharpen(enabled: setting.enableSharpen)
    }

    private func resolvedPlaybackRoute(for channel: LiveStreamChannel) -> [LiveSportStreamURL.WatchStreamRoute] {
        if entryMode == .experience {
            let custom = currentSetting.customStreamURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: currentSetting),
               !custom.isEmpty {
                return [
                    LiveSportStreamURL.WatchStreamRoute(quality: currentQuality,
                                                        displayTitle: currentQuality.displayTitle,
                                                        nominalBitrate: currentQuality.nominalBitrate,
                                                        url: custom,
                                                        streamProtocol: resolvedSetting.streamProtocol,
                                                        isABR: false)
                ]
            }
        }

        return LiveSportStreamURL.watchStreamRoute(channel: channel,
                                                   quality: currentQuality,
                                                   setting: currentSetting)
    }

    private func applyCurrentPlaybackRoute() {
        guard let channel = currentChannel else { return }
        let routes = resolvedPlaybackRoute(for: channel)
        player.switchStream(routes: routes, defaultQuality: currentQuality)
        landscapeControlsView.updateQuality(text: currentQuality.displayTitle)
        if !isPlaying {
            player.pause()
        }
    }

    private func closePage() {
        if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc
    private func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let isHiding = notification.name == UIResponder.keyboardWillHideNotification
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let convertedFrame = view.convert(keyboardFrame, from: nil)
        let intersection = view.bounds.intersection(convertedFrame)
        let bottomInset = isHiding ? 0 : max(intersection.height - view.safeAreaInsets.bottom, 0)
        let keyboardVisible = bottomInset > 0
        let inputEditing = inputBarView.isInputEditing
        let ownsKeyboardTransition = inputEditing || (isHiding && isKeyboardVisible)
        guard ownsKeyboardTransition else { return }

        isKeyboardVisible = keyboardVisible

        let keyboardGap: CGFloat = 8

        if isLandscapeMode {
            if keyboardVisible || inputEditing {
                inputBarView.isHidden = false
                view.bringSubviewToFront(inputBarView)
                inputBarView.setAccessoryButtonsHidden(true, animated: false)
                inputBarBottomConstraint?.update(offset: keyboardVisible ? -(bottomInset + keyboardGap) : -keyboardGap)
            } else {
                inputBarBottomConstraint?.update(offset: -keyboardGap)
            }
        } else {
            inputBarBottomConstraint?.update(offset: keyboardVisible ? -(bottomInset + keyboardGap) : 0)
            inputBarView.setAccessoryButtonsHidden(keyboardVisible, animated: false)
        }

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [UIView.AnimationOptions(rawValue: curveRaw << 16), .beginFromCurrentState]) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if self.isLandscapeMode && !keyboardVisible && !self.inputBarView.isInputEditing {
                self.inputBarView.isHidden = true
            }
        }
    }
}

extension LiveSportWatchViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        guard isKeyboardVisible || inputBarView.isInputEditing else { return false }
        guard let touchedView = touch.view else { return true }
        return !touchedView.isDescendant(of: inputBarView)
    }
}
