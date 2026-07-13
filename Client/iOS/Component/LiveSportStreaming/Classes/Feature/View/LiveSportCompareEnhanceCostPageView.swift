// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Combined page view for the "image enhancement" and "cost saving" compare
/// pages. Both share the structure (info card + control row + two stacked video
/// tiles); the control row differs by mode.
public final class LiveSportCompareEnhanceCostPageView: UIView {

    public enum Mode {
        case enhance
        case cost
    }

    // Enhance-mode callbacks.
    public var onSuperResolution: ((Bool) -> Void)?
    public var onSharpen: ((Bool) -> Void)?
    // Cost-mode callback.
    public var onCostModeSelect: ((Int) -> Void)?

    public let infoCard = LiveSportCompareInfoCardView()
    public let topTile = LiveSportCompareVideoTile()
    public let bottomTile = LiveSportCompareVideoTile()

    private let mode: Mode
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let superResolutionSwitch = UISwitch()
    private let sharpenSwitch = UISwitch()
    private let costPill = LiveSportComparePillSegment()

    private let switchOnColor = UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    private let labelColor = UIColor(red: 66.0 / 255.0, green: 70.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)

    public init(mode: Mode) {
        self.mode = mode
        super.init(frame: .zero)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }

        switch mode {
        case .enhance:
            infoCard.configure(body: LiveSportL10n("live_sport_compare_enhance_desc"),
                               docTitle: LiveSportL10n("live_sport_compare_view_doc"))
        case .cost:
            infoCard.configure(body: LiveSportL10n("live_sport_compare_cost_desc"),
                               bullets: [
                                   LiveSportL10n("live_sport_compare_cost_bullet1"),
                                   LiveSportL10n("live_sport_compare_cost_bullet2")
                               ],
                               docTitle: LiveSportL10n("live_sport_compare_view_doc"))
        }
        contentStack.addArrangedSubview(infoCard)
        contentStack.addArrangedSubview(makeFeatureCard())
    }

    private func makeFeatureCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 16
        inner.alignment = .fill
        card.addSubview(inner)
        inner.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        inner.addArrangedSubview(makeControlRow())

        topTile.snp.makeConstraints { make in
            make.height.equalTo(topTile.snp.width).multipliedBy(9.0 / 16.0)
        }
        bottomTile.snp.makeConstraints { make in
            make.height.equalTo(bottomTile.snp.width).multipliedBy(9.0 / 16.0)
        }
        inner.addArrangedSubview(topTile)
        inner.addArrangedSubview(bottomTile)
        return card
    }

    private func makeControlRow() -> UIView {
        switch mode {
        case .enhance:
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 24
            row.alignment = .center
            row.distribution = .fill

            superResolutionSwitch.onTintColor = switchOnColor
            superResolutionSwitch.isOn = true
            superResolutionSwitch.addAction(UIAction { [weak self] _ in
                self?.onSuperResolution?(self?.superResolutionSwitch.isOn ?? false)
            }, for: .valueChanged)

            sharpenSwitch.onTintColor = switchOnColor
            sharpenSwitch.isOn = true
            sharpenSwitch.addAction(UIAction { [weak self] _ in
                self?.onSharpen?(self?.sharpenSwitch.isOn ?? false)
            }, for: .valueChanged)

            row.addArrangedSubview(makeSwitchItem(title: LiveSportL10n("live_sport_compare_sr_full"), control: superResolutionSwitch))
            row.addArrangedSubview(makeSwitchItem(title: LiveSportL10n("live_sport_compare_sharpen_full"), control: sharpenSwitch))
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            row.addArrangedSubview(spacer)
            return row
        case .cost:
            costPill.configure(titles: [
                LiveSportL10n("live_sport_compare_cost_mode_bitrate"),
                LiveSportL10n("live_sport_compare_cost_mode_quality")
            ], selected: 0)
            costPill.onSelect = { [weak self] index in
                self?.onCostModeSelect?(index)
            }
            let wrapper = UIView()
            wrapper.addSubview(costPill)
            costPill.snp.makeConstraints { make in
                make.top.bottom.leading.trailing.equalToSuperview()
            }
            return wrapper
        }
    }

    private func makeSwitchItem(title: String, control: UISwitch) -> UIView {
        let item = UIStackView()
        item.axis = .horizontal
        item.spacing = 8
        item.alignment = .center
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = labelColor
        item.addArrangedSubview(label)
        item.addArrangedSubview(control)
        return item
    }
}
