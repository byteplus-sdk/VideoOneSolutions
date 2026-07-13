// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportExperienceCardView: UIControl {

    public var action: (() -> Void)?

    private let shadowView = UIView()
    private let backgroundView = UIView()
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(title: String, description: String, buttonTitle: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        actionButton.setTitle(buttonTitle, for: .normal)
    }

    private func setupSubviews() {
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.05
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.shadowRadius = 10
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(96)
        }

        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.masksToBounds = true
        shadowView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backgroundImageView.image = LiveSportImage(named: "live_sport_input_cell_bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        actionButton.backgroundColor = UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        actionButton.layer.cornerRadius = 8
        backgroundView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(83)
            make.height.equalTo(32)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        backgroundView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-16)
            make.top.equalToSuperview().offset(28)
        }

        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = UIColor(red: 105.0 / 255.0, green: 105.0 / 255.0, blue: 105.0 / 255.0, alpha: 0.8)
        descriptionLabel.numberOfLines = 2
        backgroundView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-100)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        actionButton.addAction(UIAction { [weak self] _ in
            self?.action?()
        }, for: .touchUpInside)
        addAction(UIAction { [weak self] _ in
            self?.action?()
        }, for: .touchUpInside)
    }
}
