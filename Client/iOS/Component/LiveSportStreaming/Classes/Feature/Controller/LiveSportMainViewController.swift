// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Top-level catalog page aligned with the Figma-designed live sport feature hub.
public final class LiveSportMainViewController: LiveSportViewController {

    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 246.0/255.0, green: 250.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        setupSubviews()
        setupCards()
    }

    private func setupSubviews() {
        setupBackground()

        view.addSubview(scrollView)
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupHeader()

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(122)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }

        view.bringSubviewToFront(headerView)
    }

    private func setupBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.image = LiveSportImage(named: "live_sport_main_bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(88)
        }

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 2.0/255.0, green: 8.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.size.equalTo(24)
        }

        titleLabel.text = LiveSportL10n("live_sport_main_title")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 2.0/255.0, green: 8.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
        }
    }

    private func setupCards() {
        let watchCard = LiveSportFeatureCardView()
        watchCard.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        watchCard.configure(title: LiveSportL10n("live_sport_main_watch_card_title"),
                            description: LiveSportL10n("live_sport_main_watch_card_des"),
                            badgeTitle: LiveSportL10n("live_sport_main_live_badge"),
                            badgeStyle: .live,
                            image: LiveSportImage(named: "live_sport_main_watch_bg"),
                            showsCompareOverlay: false)
        watchCard.action = { [weak self] in
            self?.pushWatch()
        }
        stackView.addArrangedSubview(watchCard)

        let compareCard = LiveSportFeatureCardView()
        compareCard.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        compareCard.configure(title: LiveSportL10n("live_sport_main_compare_card_title"),
                              description: LiveSportL10n("live_sport_main_compare_card_des"),
                              badgeTitle: LiveSportL10n("live_sport_main_compare_badge"),
                              badgeStyle: .compare,
                              image: LiveSportImage(named: "live_sport_main_compare_bg"),
                              showsCompareOverlay: true)
        compareCard.action = { [weak self] in
            self?.pushCompare()
        }
        stackView.addArrangedSubview(compareCard)

        let inputCard = LiveSportExperienceCardView()
        inputCard.snp.makeConstraints { make in
            make.height.equalTo(96)
        }
        inputCard.configure(title: LiveSportL10n("live_sport_main_input_card_title"),
                            description: LiveSportL10n("live_sport_main_input_card_des"),
                            buttonTitle: LiveSportL10n("live_sport_main_input_cta"))
        inputCard.action = { [weak self] in
            self?.pushSetting()
        }
        stackView.addArrangedSubview(inputCard)
    }

    private func pushWatch() {
        navigationController?.pushViewController(LiveSportWatchViewController(), animated: true)
    }

    private func pushSetting() {
        navigationController?.pushViewController(LiveSportSettingViewController(), animated: true)
    }

    private func pushCompare() {
        navigationController?.pushViewController(LiveSportCompareViewController(), animated: true)
    }
}
