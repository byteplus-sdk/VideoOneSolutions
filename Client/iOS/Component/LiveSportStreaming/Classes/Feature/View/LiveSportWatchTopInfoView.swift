// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

public final class LiveSportWatchTopInfoView: UIView {

    public var onFollowTap: (() -> Void)?
    public var onCloseTap: (() -> Void)?

    private let infoContainerView = UIView()
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let hotIconView = UIImageView()
    private let statusLabel = UILabel()
    private let followButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(anchorName: String,
                          statusText: String,
                          avatarURL: String,
                          avatarImage: UIImage?,
                          isFollowed: Bool) {
        nameLabel.text = anchorName
        statusLabel.text = statusText
        if !avatarURL.isEmpty, let url = URL(string: avatarURL) {
            avatarView.sd_setImage(with: url, placeholderImage: avatarImage)
        } else {
            avatarView.image = avatarImage
        }
        updateFollowState(isFollowed: isFollowed)
    }

    public func updateFollowState(isFollowed: Bool) {
        let title = isFollowed ? LiveSportL10n("live_sport_followed") : LiveSportL10n("live_sport_follow")
        followButton.setTitle(title, for: .normal)
        followButton.backgroundColor = isFollowed ? UIColor.white.withAlphaComponent(0.12) : UIColor(red: 1.0, green: 43.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
        followButton.setTitleColor(.white, for: .normal)
    }

    public func setInfoHidden(_ hidden: Bool) {
        infoContainerView.isHidden = hidden
    }

    private func setupSubviews() {
        addSubview(infoContainerView)
        addSubview(closeButton)

        infoContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.36)
        infoContainerView.layer.cornerRadius = 18
        infoContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(54)
            make.height.equalTo(36)
            make.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-8)
        }

        avatarView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        avatarView.layer.cornerRadius = 16
        avatarView.layer.masksToBounds = true
        avatarView.contentMode = .scaleAspectFill
        infoContainerView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        followButton.layer.cornerRadius = 14
        followButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        followButton.addAction(UIAction { [weak self] _ in
            self?.onFollowTap?()
        }, for: .touchUpInside)
        infoContainerView.addSubview(followButton)
        followButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor = .white
        infoContainerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(avatarView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-8).priority(.low)
        }

        hotIconView.image = LiveSportImage(named: "sport_hot_icon")?.withRenderingMode(.alwaysOriginal)
        hotIconView.contentMode = .scaleAspectFit
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
            make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-8).priority(.low)
        }

        closeButton.setImage(LiveSportImage(named: "sport_close")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        closeButton.layer.cornerRadius = 12
        closeButton.addAction(UIAction { [weak self] _ in
            self?.onCloseTap?()
        }, for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(infoContainerView)
            make.size.equalTo(24)
        }
    }
}
