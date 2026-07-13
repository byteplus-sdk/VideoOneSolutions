// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportFeatureCardView: UIControl {

    public enum BadgeStyle {
        case live
        case compare
    }

    public var action: (() -> Void)?

    private let contentView = UIView()
    private let imageView = UIImageView()
    private let badgeView = UIView()
    private let badgeDotView = UIView()
    private let badgeLabel = UILabel()
    private let gradientOverlayView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let compareOverlayView = UIView()
    private let dividerView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(title: String,
                          description: String,
                          badgeTitle: String,
                          badgeStyle: BadgeStyle,
                          image: UIImage?,
                          showsCompareOverlay: Bool) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
        badgeLabel.text = badgeTitle
        compareOverlayView.isHidden = !showsCompareOverlay
        dividerView.isHidden = !showsCompareOverlay

        switch badgeStyle {
        case .live:
            badgeView.backgroundColor = UIColor(red: 254.0 / 255.0, green: 44.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
            badgeDotView.isHidden = false
            badgeDotView.backgroundColor = .white
        case .compare:
            badgeView.backgroundColor = UIColor.black.withAlphaComponent(0.32)
            badgeDotView.isHidden = true
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if gradientOverlayView.layer.sublayers?.isEmpty ?? true {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.0).cgColor,
                UIColor.black.withAlphaComponent(0.12).cgColor,
                UIColor.black.withAlphaComponent(0.62).cgColor
            ]
            gradientLayer.locations = [0.0, 0.55, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.frame = gradientOverlayView.bounds
            gradientOverlayView.layer.addSublayer(gradientLayer)
        } else {
            gradientOverlayView.layer.sublayers?.first?.frame = gradientOverlayView.bounds
        }
    }

    private func setupSubviews() {
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 10

        addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.isUserInteractionEnabled = false
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(160)
        }

        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        compareOverlayView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        compareOverlayView.isHidden = true
        contentView.addSubview(compareOverlayView)
        compareOverlayView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        dividerView.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        dividerView.isHidden = true
        contentView.addSubview(dividerView)
        dividerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(2)
            make.centerX.equalToSuperview()
        }

        badgeView.layer.cornerRadius = 10
        badgeView.layer.masksToBounds = true
        contentView.addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.height.equalTo(20)
        }

        badgeDotView.layer.cornerRadius = 2
        badgeView.addSubview(badgeDotView)
        badgeDotView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(4)
        }

        badgeLabel.font = UIFont.systemFont(ofSize: 10)
        badgeLabel.textColor = .white
        badgeView.addSubview(badgeLabel)
        badgeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(badgeDotView.snp.trailing).offset(4)
        }

        contentView.addSubview(gradientOverlayView)
        gradientOverlayView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(84)
        }

        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 2
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-4)
        }

        addAction(UIAction { [weak self] _ in
            self?.action?()
        }, for: .touchUpInside)
    }
}
