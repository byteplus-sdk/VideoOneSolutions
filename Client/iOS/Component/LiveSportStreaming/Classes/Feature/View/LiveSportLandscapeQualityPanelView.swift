// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Landscape quality panel shown as a right-side slide-in list.
public final class LiveSportLandscapeQualityPanelView: UIView {

    public static let preferredWidth: CGFloat = 240

    public var onSelectQuality: ((LiveSportStreamURL.WatchQualityOption) -> Void)?

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let listStackView = UIStackView()
    private var options: [LiveSportStreamURL.WatchQualityOption] = []
    private var selectedQuality: LiveSportStreamURL.WatchQualityOption = .quality1080
    private var optionButtons: [UIButton] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(options: [LiveSportStreamURL.WatchQualityOption],
                          selectedQuality: LiveSportStreamURL.WatchQualityOption) {
        self.options = options
        self.selectedQuality = selectedQuality
        rebuildOptions()
    }

    private func setupSubviews() {
        backgroundColor = UIColor.black.withAlphaComponent(0.64)

        insertSubview(blurView, at: 0)
        blurView.alpha = 0.4
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(titleLabel)
        titleLabel.text = LiveSportL10n("live_sport_quality_title")
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = UIColor(red: 180.0 / 255.0, green: 183.0 / 255.0, blue: 188.0 / 255.0, alpha: 1.0)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        scrollView.addSubview(listStackView)
        listStackView.axis = .vertical
        listStackView.spacing = 4
        listStackView.alignment = .fill
        listStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func rebuildOptions() {
        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        listStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(option.displayTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 2
            button.layer.borderWidth = 1
            button.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
            button.addAction(UIAction { [weak self] _ in
                self?.handleSelect(index: index)
            }, for: .touchUpInside)
            listStackView.addArrangedSubview(button)
            optionButtons.append(button)
        }
        updateSelectionStyle()
    }

    private func handleSelect(index: Int) {
        guard options.indices.contains(index) else { return }
        selectedQuality = options[index]
        updateSelectionStyle()
        onSelectQuality?(options[index])
    }

    private func updateSelectionStyle() {
        for (index, button) in optionButtons.enumerated() {
            let isSelected = options[index] == selectedQuality
            button.backgroundColor = isSelected
                ? UIColor.white.withAlphaComponent(0.12)
                : .clear
            button.layer.borderColor = isSelected
                ? UIColor.white.withAlphaComponent(0.3).cgColor
                : UIColor.clear.cgColor
            button.setTitleColor(.white, for: .normal)
        }
    }
}
