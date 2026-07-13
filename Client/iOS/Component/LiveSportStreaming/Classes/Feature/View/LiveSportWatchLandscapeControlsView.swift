// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Landscape controls overlay rendered on top of the full-screen player.
/// Hosts the top bar (back / anchor / follow / popularity / settings),
/// the bottom bar (play-pause / input / multi-camera / quality / rotate)
/// and a left-center lock button.
public final class LiveSportWatchLandscapeControlsView: UIView {

    public var onBackTap: (() -> Void)?
    public var onFollowTap: (() -> Void)?
    public var onSettingsTap: (() -> Void)?
    public var onLockTap: (() -> Void)?
    public var onPlayPauseTap: (() -> Void)?
    public var onGiftTap: (() -> Void)?
    public var onMultiCameraTap: (() -> Void)?
    public var onQualityTap: (() -> Void)?
    public var onInputTap: (() -> Void)?
    public var onAutoHide: (() -> Void)?

    // Top bar
    private let topBar = UIView()
    private let topGradientLayer = CAGradientLayer()
    private let backButton = UIButton(type: .system)
    private let infoContainerView = UIView()
    private let nameLabel = UILabel()
    private let hotIconView = UIImageView()
    private let statusLabel = UILabel()
    private let followButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)

    // Bottom bar
    private let bottomBar = UIView()
    private let bottomGradientLayer = CAGradientLayer()
    private let playPauseButton = UIButton(type: .custom)
    private let inputPill = UIControl()
    private let inputLabel = UILabel()
    private let multiCameraControl = UIControl()
    private let multiCameraIconView = UIImageView()
    private let multiCameraLabel = UILabel()
    private let qualityButton = UIButton(type: .system)
    private let giftButton = UIButton(type: .custom)

    // Lock
    private let lockButton = UIButton(type: .system)

    private var isControlsHidden = false
    private var isLocked = false
    private var isLockedControlsHidden = false
    private let autoHideDelay: TimeInterval = 2.0
    private var autoHideWorkItem: DispatchWorkItem?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topBar.bounds
        bottomGradientLayer.frame = bottomBar.bounds
    }

    /// Lets taps on empty areas fall through to the player view below so the
    /// middle-area tap can toggle the controls. Only actual control subviews
    /// (and visible bars) capture touches.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit === self {
            return nil
        }
        return hit
    }

    // MARK: - Public

    public func configure(anchorName: String, isFollowed: Bool, isPlaying: Bool, qualityText: String) {
        nameLabel.text = anchorName
        statusLabel.text = LiveSportL10n("live_sport_watch_host_status")
        updateFollow(isFollowed: isFollowed)
        updatePlayPause(isPlaying: isPlaying)
        updateQuality(text: qualityText)
    }

    public func updatePlayPause(isPlaying: Bool) {
        let name = isPlaying ? "sport_video_pause" : "sport_video_play"
        playPauseButton.setImage(LiveSportImage(named: name)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    public func updateFollow(isFollowed: Bool) {
        let title = isFollowed ? LiveSportL10n("live_sport_followed") : LiveSportL10n("live_sport_follow")
        followButton.setTitle(title, for: .normal)
        followButton.backgroundColor = isFollowed
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor(red: 254.0 / 255.0, green: 44.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    }

    public func updateQuality(text: String) {
        qualityButton.setTitle(text, for: .normal)
    }

    public func setMode(showMultiCamera: Bool, showQuality: Bool) {
        multiCameraControl.isHidden = !showMultiCamera
        multiCameraControl.isUserInteractionEnabled = showMultiCamera
        multiCameraIconView.isHidden = !showMultiCamera
        multiCameraLabel.isHidden = !showMultiCamera
        qualityButton.isHidden = !showQuality
        qualityButton.isUserInteractionEnabled = showQuality
    }

    /// Center of the gift button converted into the given coordinate space, used
    /// as the start point of the gift float-up animation in landscape.
    public func giftButtonCenter(in coordinateSpace: UICoordinateSpace) -> CGPoint {
        let center = CGPoint(x: giftButton.bounds.midX, y: giftButton.bounds.midY)
        return giftButton.convert(center, to: coordinateSpace)
    }

    public func setControlsHidden(_ hidden: Bool, animated: Bool) {
        isControlsHidden = hidden
        if hidden {
            cancelAutoHide()
        }
        let changes = {
            let topAlpha: CGFloat = hidden ? 0 : 1
            self.topBar.alpha = topAlpha
            self.bottomBar.alpha = topAlpha
            self.lockButton.alpha = topAlpha
            self.topBar.transform = hidden ? CGAffineTransform(translationX: 0, y: -12) : .identity
            self.bottomBar.transform = hidden ? CGAffineTransform(translationX: 0, y: 12) : .identity
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: changes) { _ in
                if !hidden {
                    self.scheduleAutoHideIfNeeded()
                }
                self.updateInteractionState()
            }
        } else {
            changes()
            if !hidden {
                scheduleAutoHideIfNeeded()
            }
            updateInteractionState()
        }
    }

    public func showThenAutoHide(animated: Bool) {
        setControlsHidden(false, animated: animated)
    }

    public func cancelAutoHide() {
        autoHideWorkItem?.cancel()
        autoHideWorkItem = nil
    }

    /// When locked, only the back button and the lock button remain visible.
    public func setLocked(_ locked: Bool, animated: Bool) {
        isLocked = locked
        isLockedControlsHidden = false
        if locked {
            cancelAutoHide()
        }
        lockButton.setImage(UIImage(systemName: locked ? "lock.fill" : "lock.open.fill"), for: .normal)
        let changes = {
            let alpha: CGFloat = locked ? 0 : 1
            self.infoContainerView.alpha = alpha
            self.settingsButton.alpha = alpha
            self.bottomBar.alpha = locked ? 0 : (self.isControlsHidden ? 0 : 1)
            self.backButton.alpha = 1
            self.topBar.alpha = 1
            self.lockButton.alpha = 1
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: changes) { _ in
                if !locked && !self.isControlsHidden {
                    self.scheduleAutoHideIfNeeded()
                }
                self.updateInteractionState()
            }
        } else {
            changes()
            if !locked && !isControlsHidden {
                scheduleAutoHideIfNeeded()
            }
            updateInteractionState()
        }
    }

    /// While locked, a tap on the player toggles the visibility of the back and
    /// lock buttons (the only controls available in the locked state).
    public func toggleLockedControls(animated: Bool) {
        guard isLocked else { return }
        isLockedControlsHidden.toggle()
        let alpha: CGFloat = isLockedControlsHidden ? 0 : 1
        let changes = {
            self.backButton.alpha = alpha
            self.lockButton.alpha = alpha
            self.topBar.alpha = alpha
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: changes) { _ in
                self.updateInteractionState()
            }
        } else {
            changes()
            updateInteractionState()
        }
    }

    private func updateInteractionState() {
        let controlsVisible = !isControlsHidden
        infoContainerView.isUserInteractionEnabled = controlsVisible && !isLocked
        settingsButton.isUserInteractionEnabled = controlsVisible && !isLocked
        bottomBar.isUserInteractionEnabled = controlsVisible && !isLocked
        let lockedControlsVisible = isLocked && !isLockedControlsHidden
        backButton.isUserInteractionEnabled = (controlsVisible && !isLocked) || lockedControlsVisible
        lockButton.isUserInteractionEnabled = controlsVisible || lockedControlsVisible
    }

    private func scheduleAutoHideIfNeeded() {
        cancelAutoHide()
        guard !isLocked, !isControlsHidden else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isLocked, !self.isControlsHidden else { return }
            self.setControlsHidden(true, animated: true)
            self.onAutoHide?()
        }
        autoHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + autoHideDelay, execute: workItem)
    }

    // MARK: - Setup

    private func setupSubviews() {
        backgroundColor = .clear
        setupTopBar()
        setupBottomBar()
        setupLockButton()
    }

    private func setupTopBar() {
        addSubview(topBar)
        topBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(88)
        }
        topGradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        topBar.layer.addSublayer(topGradientLayer)

        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        backButton.tintColor = .white
        backButton.addAction(UIAction { [weak self] _ in self?.onBackTap?() }, for: .touchUpInside)
        topBar.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading).offset(12)
            make.top.equalToSuperview().offset(20)
            make.size.equalTo(32)
        }

        infoContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        infoContainerView.layer.cornerRadius = 18
        topBar.addSubview(infoContainerView)
        infoContainerView.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.centerY.equalTo(backButton)
            make.height.equalTo(36)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .white
        infoContainerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(4)
        }

        hotIconView.image = UIImage(systemName: "flame.fill")
        hotIconView.tintColor = UIColor(red: 1.0, green: 114.0 / 255.0, blue: 95.0 / 255.0, alpha: 1.0)
        infoContainerView.addSubview(hotIconView)
        hotIconView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-5)
            make.size.equalTo(10)
        }

        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        infoContainerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(hotIconView)
            make.leading.equalTo(hotIconView.snp.trailing).offset(3)
        }

        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        followButton.setTitleColor(.white, for: .normal)
        followButton.layer.cornerRadius = 12
        followButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        followButton.addAction(UIAction { [weak self] _ in self?.onFollowTap?() }, for: .touchUpInside)
        infoContainerView.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(8)
            make.leading.greaterThanOrEqualTo(statusLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
        }

        settingsButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        settingsButton.layer.cornerRadius = 18
        settingsButton.addAction(UIAction { [weak self] _ in self?.onSettingsTap?() }, for: .touchUpInside)
        topBar.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-12)
            make.centerY.equalTo(backButton)
            make.size.equalTo(36)
        }
    }

    private func setupBottomBar() {
        addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        bottomGradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bottomBar.layer.addSublayer(bottomGradientLayer)

        playPauseButton.adjustsImageWhenHighlighted = false
        playPauseButton.addAction(UIAction { [weak self] _ in self?.onPlayPauseTap?() }, for: .touchUpInside)
        bottomBar.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading).offset(16)
            make.bottom.equalToSuperview().offset(-20)
            make.size.equalTo(24)
        }

        inputPill.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        inputPill.layer.cornerRadius = 19
        inputPill.addAction(UIAction { [weak self] _ in self?.onInputTap?() }, for: .touchUpInside)
        bottomBar.addSubview(inputPill)
        inputPill.snp.makeConstraints { make in
            make.leading.equalTo(playPauseButton.snp.trailing).offset(12)
            make.centerY.equalTo(playPauseButton)
            make.width.equalTo(200)
            make.height.equalTo(38)
        }

        inputLabel.text = LiveSportL10n("live_sport_say_something")
        inputLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        inputLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        inputLabel.isUserInteractionEnabled = false
        inputPill.addSubview(inputLabel)
        inputLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        giftButton.setImage(LiveSportImage(named: "sport_gift_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        giftButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        giftButton.layer.cornerRadius = 18
        giftButton.adjustsImageWhenHighlighted = false
        giftButton.addAction(UIAction { [weak self] _ in self?.onGiftTap?() }, for: .touchUpInside)
        bottomBar.addSubview(giftButton)
        giftButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).offset(-12)
            make.centerY.equalTo(playPauseButton)
            make.size.equalTo(36)
        }

        qualityButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        qualityButton.setTitleColor(.white, for: .normal)
        qualityButton.setTitle("1080P", for: .normal)
        qualityButton.addAction(UIAction { [weak self] _ in self?.onQualityTap?() }, for: .touchUpInside)
        bottomBar.addSubview(qualityButton)
        qualityButton.snp.makeConstraints { make in
            make.trailing.equalTo(giftButton.snp.leading).offset(-16)
            make.centerY.equalTo(playPauseButton)
        }

        multiCameraControl.addAction(UIAction { [weak self] _ in self?.onMultiCameraTap?() }, for: .touchUpInside)
        bottomBar.addSubview(multiCameraControl)
        multiCameraControl.snp.makeConstraints { make in
            make.trailing.equalTo(qualityButton.snp.leading).offset(-16)
            make.centerY.equalTo(playPauseButton)
            make.height.equalTo(36)
        }

        multiCameraIconView.image = LiveSportImage(named: "sport_watcher_mutil_camera")?.withRenderingMode(.alwaysOriginal)
        multiCameraIconView.contentMode = .scaleAspectFit
        multiCameraIconView.isUserInteractionEnabled = false
        multiCameraControl.addSubview(multiCameraIconView)
        multiCameraIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        multiCameraLabel.text = LiveSportL10n("live_sport_multi_camera")
        multiCameraLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        multiCameraLabel.textColor = .white
        multiCameraLabel.isUserInteractionEnabled = false
        multiCameraLabel.setContentHuggingPriority(.required, for: .horizontal)
        multiCameraLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        multiCameraControl.addSubview(multiCameraLabel)
        multiCameraLabel.snp.makeConstraints { make in
            make.leading.equalTo(multiCameraIconView.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func setupLockButton() {
        lockButton.setImage(UIImage(systemName: "lock.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)), for: .normal)
        lockButton.tintColor = .white
        lockButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        lockButton.layer.cornerRadius = 18
        lockButton.addAction(UIAction { [weak self] _ in self?.onLockTap?() }, for: .touchUpInside)
        addSubview(lockButton)
        lockButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading).offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
    }
}
