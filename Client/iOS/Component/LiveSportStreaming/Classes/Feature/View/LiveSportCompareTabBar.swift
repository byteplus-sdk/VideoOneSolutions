// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Top L2 tab bar for the Compare page: back arrow + three selectable tabs with
/// an animated underline indicator.
public final class LiveSportCompareTabBar: UIView {

    public var onBack: (() -> Void)?
    public var onSelect: ((Int) -> Void)?

    private let backButton = UIButton(type: .system)
    private let tabsScrollView = UIScrollView()
    private let tabsContentView = UIView()
    private let tabStack = UIStackView()
    private let indicator = UIView()
    private var tabButtons: [UIButton] = []
    private var selectedIndex: Int = 0

    private let selectedColor = UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    private let normalColor = UIColor(red: 66.0 / 255.0, green: 70.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)

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
        centerContentIfNeeded()
    }

    public func setSelected(index: Int, animated: Bool) {
        guard index >= 0, index < tabButtons.count else { return }
        selectedIndex = index
        for (i, button) in tabButtons.enumerated() {
            let isSelected = i == index
            button.setTitleColor(isSelected ? selectedColor : normalColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: isSelected ? .medium : .regular)
        }
        layoutIfNeeded()
        let target = tabButtons[index]
        let updates = {
            self.indicator.snp.remakeConstraints { make in
                make.centerX.equalTo(target)
                make.bottom.equalToSuperview()
                make.width.equalTo(19)
                make.height.equalTo(2)
            }
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
        scrollSelectedTabIntoView(animated: animated)
    }

    private func setupSubviews() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        backButton.addAction(UIAction { [weak self] _ in
            self?.onBack?()
        }, for: .touchUpInside)
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        tabsScrollView.showsHorizontalScrollIndicator = false
        tabsScrollView.alwaysBounceHorizontal = false
        tabsScrollView.alwaysBounceVertical = false
        addSubview(tabsScrollView)
        tabsScrollView.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
        }

        tabsScrollView.addSubview(tabsContentView)
        tabsContentView.snp.makeConstraints { make in
            make.edges.equalTo(tabsScrollView.contentLayoutGuide)
            make.height.equalTo(tabsScrollView.frameLayoutGuide)
        }

        tabStack.axis = .horizontal
        tabStack.spacing = 32
        tabStack.alignment = .center
        tabStack.distribution = .fill
        tabsContentView.addSubview(tabStack)
        tabStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let titles = [
            LiveSportL10n("live_sport_compare_low_latency"),
            LiveSportL10n("live_sport_compare_image_enhance"),
            LiveSportL10n("live_sport_compare_cost_save")
        ]
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(normalColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            button.contentEdgeInsets = .zero
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.addAction(UIAction { [weak self] _ in
                self?.onSelect?(index)
            }, for: .touchUpInside)
            tabButtons.append(button)
            tabStack.addArrangedSubview(button)
        }

        indicator.backgroundColor = selectedColor
        indicator.layer.cornerRadius = 1
        tabsContentView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalTo(tabButtons[0])
            make.bottom.equalToSuperview()
            make.width.equalTo(19)
            make.height.equalTo(2)
        }

        setSelected(index: 0, animated: false)
    }

    private func centerContentIfNeeded() {
        tabsScrollView.layoutIfNeeded()
        let contentWidth = tabStack.bounds.width
        let availableWidth = tabsScrollView.bounds.width
        guard availableWidth > 0 else { return }
        let horizontalInset = contentWidth < availableWidth ? (availableWidth - contentWidth) / 2.0 : 0
        let newInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        if tabsScrollView.contentInset != newInset {
            tabsScrollView.contentInset = newInset
        }
    }

    private func scrollSelectedTabIntoView(animated: Bool) {
        guard selectedIndex >= 0, selectedIndex < tabButtons.count else { return }
        tabsScrollView.layoutIfNeeded()

        let contentWidth = tabStack.bounds.width
        let availableWidth = tabsScrollView.bounds.width
        guard contentWidth > availableWidth else { return }

        let targetButton = tabButtons[selectedIndex]
        let targetFrame = targetButton.convert(targetButton.bounds, to: tabsContentView)
        let horizontalPadding: CGFloat = 24
        let targetMinX = max(0, targetFrame.midX - availableWidth / 2.0)
        let maxOffsetX = max(0, contentWidth - availableWidth)
        let preferredOffsetX = min(max(targetMinX, 0), maxOffsetX)
        let visibleRect = CGRect(x: max(preferredOffsetX - horizontalPadding, 0),
                                 y: 0,
                                 width: min(availableWidth + horizontalPadding * 2.0, contentWidth),
                                 height: tabsScrollView.bounds.height)
        tabsScrollView.scrollRectToVisible(visibleRect, animated: animated)
    }
}
