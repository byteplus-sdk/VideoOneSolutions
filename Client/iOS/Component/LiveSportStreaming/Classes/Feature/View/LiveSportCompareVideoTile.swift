// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// A single video region: hosts an external player render view, with a leading
/// badge (delay/bitrate), an optional trailing badge (codec), and play/pause +
/// mute controls along the bottom.
public final class LiveSportCompareVideoTile: UIView {

    public var onPlayPause: (() -> Void)?
    public var onMute: (() -> Void)?

    /// Container that holds the externally-owned player render view.
    public let hostContainer = UIView()

    private let leadingBadge = PaddingLabel()
    private let trailingBadge = PaddingLabel()
    private let playPauseButton = UIButton(type: .system)
    private let muteButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setLeadingBadge(_ text: String) {
        leadingBadge.text = text
    }

    public func setTrailingBadge(_ text: String?) {
        if let text = text, !text.isEmpty {
            trailingBadge.text = text
            trailingBadge.isHidden = false
        } else {
            trailingBadge.isHidden = true
        }
    }

    public func setPlaying(_ playing: Bool) {
        let imageName = playing ? "sport_video_pause" : "sport_video_play"
        playPauseButton.setImage(LiveSportImage(named: imageName), for: .normal)
    }

    public func setMuted(_ muted: Bool) {
        let symbol = muted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteButton.setImage(UIImage(systemName: symbol), for: .normal)
    }

    public func attach(renderView: UIView) {
        hostContainer.subviews.forEach { $0.removeFromSuperview() }
        renderView.removeFromSuperview()
        hostContainer.addSubview(renderView)
        renderView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSubviews() {
        backgroundColor = .black
        layer.cornerRadius = 8
        layer.masksToBounds = true

        addSubview(hostContainer)
        hostContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        configureBadge(leadingBadge)
        addSubview(leadingBadge)
        leadingBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
        }

        configureBadge(trailingBadge)
        trailingBadge.isHidden = true
        addSubview(trailingBadge)
        trailingBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        playPauseButton.tintColor = .white
        playPauseButton.setImage(LiveSportImage(named: "sport_video_pause"), for: .normal)
        playPauseButton.addAction(UIAction { [weak self] _ in
            self?.onPlayPause?()
        }, for: .touchUpInside)
        addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }

        muteButton.tintColor = .white
        muteButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        muteButton.addAction(UIAction { [weak self] _ in
            self?.onMute?()
        }, for: .touchUpInside)
        addSubview(muteButton)
        muteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }
    }

    private func configureBadge(_ label: PaddingLabel) {
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
}

/// Label with configurable text insets, used for the corner badges.
private final class PaddingLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
