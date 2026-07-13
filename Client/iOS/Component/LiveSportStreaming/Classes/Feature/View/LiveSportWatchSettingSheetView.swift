// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportWatchSettingSheetView: UIView {

    public var onClose: (() -> Void)?
    public var onSave: ((LiveSetting) -> Void)?

    private let contentStackView = UIStackView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let protocolRowButton = UIButton(type: .system)
    private let protocolTitleLabel = UILabel()
    private let protocolValueLabel = UILabel()
    private let protocolArrowView = UIImageView()
    private let protocolSelectorContainer = UIView()

    private let protocolMenuBackdrop = UIControl()
    private let protocolMenuContainerView = UIView()
    private let protocolMenuScrollView = UIScrollView()
    private let protocolMenuStackView = UIStackView()
    private var protocolOptionButtons: [UIButton] = []
    private var protocolMenuHeightConstraint: Constraint?

    private let abrSwitch = UISwitch()
    private let superResolutionSwitch = UISwitch()
    private let sharpenSwitch = UISwitch()
    private let switchesStackView = UIStackView()
    private var abrRow: UIView?
    private let saveButton = UIButton(type: .system)

    private var pendingSetting = LiveSetting()
    private var isProtocolListExpanded = false
    private var contentBottomConstraint: Constraint?
    private var closeButtonTrailingConstraint: Constraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        bindActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(setting: LiveSetting) {
        pendingSetting = setting
        updateProtocolRow()
        updateProtocolOptions()
        abrSwitch.isOn = setting.enableABR
        superResolutionSwitch.isOn = setting.enableSuperResolution
        sharpenSwitch.isOn = setting.enableSharpen
        setProtocolMenuVisible(false, animated: false)
        handleProtocolDependency()
    }

    /// Reuses the sheet content as a right-side slide-in panel in landscape:
    /// rounds the left corners instead of the top corners and lets content lay
    /// out from the top of the fixed-height side panel.
    public func applyLandscapeSidePanelStyle() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        contentBottomConstraint?.deactivate()
        contentStackView.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide.snp.bottom)
        }
        closeButtonTrailingConstraint?.update(offset: -20)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if isProtocolListExpanded {
            updateProtocolMenuLayout()
        }
    }

    public func setProtocolMenuVisible(_ visible: Bool, animated: Bool) {
        if visible {
            layoutIfNeeded()
            updateProtocolMenuLayout()
        }
        isProtocolListExpanded = visible
        protocolMenuBackdrop.isHidden = !visible
        protocolMenuBackdrop.isUserInteractionEnabled = visible
        protocolMenuContainerView.isHidden = false
        protocolMenuHeightConstraint?.update(offset: visible ? currentProtocolMenuHeight : 0)
        let changes = {
            self.protocolMenuBackdrop.alpha = visible ? 1.0 : 0.0
            self.protocolMenuContainerView.alpha = visible ? 1.0 : 0.0
            self.protocolMenuContainerView.transform = visible ? .identity : CGAffineTransform(translationX: 0, y: -6)
            self.protocolArrowView.transform = visible ? CGAffineTransform(rotationAngle: -.pi / 2.0) : CGAffineTransform(rotationAngle: .pi / 2.0)
            self.layoutIfNeeded()
        }
        let completion: (Bool) -> Void = { _ in
            self.protocolMenuContainerView.isHidden = !visible
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: changes,
                           completion: completion)
        } else {
            changes()
            completion(true)
        }
    }

    private var protocolMenuContentHeight: CGFloat {
        return CGFloat(StreamProtocol.allCases.count * 40)
    }

    private var currentProtocolMenuHeight: CGFloat = 0

    private func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        addSubview(contentStackView)
        contentStackView.axis = .vertical
        contentStackView.spacing = 0
        contentStackView.alignment = .fill
        contentStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            self.contentBottomConstraint = make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).constraint
        }

        setupHeader()
        setupProtocolSection()
        setupProtocolMenu()
        setupSwitchRows()
        setupFooter()
    }

    private func setupHeader() {
        headerView.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentStackView.addArrangedSubview(headerView)

        titleLabel.text = LiveSportL10n("live_sport_watch_setting_title")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 29.0 / 255.0, green: 33.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)

        closeButton.tintColor = UIColor(red: 78.0 / 255.0, green: 89.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
        closeButton.backgroundColor = UIColor(red: 242.0 / 255.0, green: 243.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
        closeButton.layer.cornerRadius = 14
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)

        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        closeButton.snp.makeConstraints { make in
            closeButtonTrailingConstraint = make.trailing.equalToSuperview().offset(-12).constraint
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
    }

    private func setupProtocolSection() {
        let container = UIView()
        contentStackView.addArrangedSubview(container)
        container.addSubview(protocolRowButton)

        protocolRowButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        protocolTitleLabel.text = LiveSportL10n("live_sport_protocol")
        protocolTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        protocolTitleLabel.textColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)

        protocolValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        protocolValueLabel.textColor = UIColor(red: 128.0 / 255.0, green: 131.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)

        protocolArrowView.image = UIImage(systemName: "chevron.right")
        protocolArrowView.tintColor = UIColor(red: 134.0 / 255.0, green: 144.0 / 255.0, blue: 156.0 / 255.0, alpha: 1.0)
        protocolArrowView.contentMode = .scaleAspectFit
        protocolArrowView.transform = CGAffineTransform(rotationAngle: .pi / 2.0)

        protocolSelectorContainer.backgroundColor = .white
        protocolSelectorContainer.layer.cornerRadius = 4
        protocolSelectorContainer.layer.borderWidth = 1
        protocolSelectorContainer.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 226.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0).cgColor
        protocolSelectorContainer.isUserInteractionEnabled = false

        protocolRowButton.addSubview(protocolTitleLabel)
        protocolRowButton.addSubview(protocolSelectorContainer)
        protocolSelectorContainer.addSubview(protocolValueLabel)
        protocolSelectorContainer.addSubview(protocolArrowView)

        protocolTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        protocolSelectorContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(116)
            make.height.equalTo(28)
        }
        protocolValueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        protocolArrowView.snp.makeConstraints { make in
            make.leading.equalTo(protocolValueLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 12))
        }

        StreamProtocol.allCases.forEach { proto in
            let button = makeProtocolOptionButton(streamProtocol: proto)
            protocolOptionButtons.append(button)
            protocolMenuStackView.addArrangedSubview(button)
        }
    }

    private func setupProtocolMenu() {
        addSubview(protocolMenuBackdrop)
        protocolMenuBackdrop.alpha = 0
        protocolMenuBackdrop.isHidden = true
        protocolMenuBackdrop.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(protocolMenuContainerView)
        protocolMenuContainerView.alpha = 0
        protocolMenuContainerView.isHidden = true
        protocolMenuContainerView.transform = CGAffineTransform(translationX: 0, y: -6)
        protocolMenuContainerView.backgroundColor = .white
        protocolMenuContainerView.layer.cornerRadius = 8
        protocolMenuContainerView.layer.borderWidth = 1
        protocolMenuContainerView.layer.borderColor = UIColor(red: 221.0 / 255.0, green: 226.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0).cgColor
        protocolMenuContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        protocolMenuContainerView.layer.shadowOpacity = 1
        protocolMenuContainerView.layer.shadowRadius = 4
        protocolMenuContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        protocolMenuContainerView.addSubview(protocolMenuScrollView)
        protocolMenuContainerView.snp.makeConstraints { make in
            make.top.equalTo(protocolRowButton.snp.bottom).offset(4)
            make.trailing.equalTo(protocolRowButton.snp.trailing)
            make.width.greaterThanOrEqualTo(116)
            self.protocolMenuHeightConstraint = make.height.equalTo(0).constraint
        }
        protocolMenuScrollView.showsVerticalScrollIndicator = false
        protocolMenuScrollView.showsHorizontalScrollIndicator = false
        protocolMenuScrollView.alwaysBounceVertical = false
        protocolMenuScrollView.bounces = false
        protocolMenuScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        protocolMenuScrollView.addSubview(protocolMenuStackView)
        protocolMenuStackView.axis = .vertical
        protocolMenuStackView.spacing = 0
        protocolMenuStackView.alignment = .fill
        protocolMenuStackView.distribution = .fill
        protocolMenuStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func setupSwitchRows() {
        let switchesContainer = UIView()
        contentStackView.addArrangedSubview(switchesContainer)

        switchesStackView.axis = .vertical
        switchesStackView.alignment = .fill
        switchesStackView.distribution = .fill
        switchesStackView.spacing = 0
        switchesContainer.addSubview(switchesStackView)
        switchesStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        let abrRow = makeSwitchRow(title: LiveSportL10n("live_sport_watch_setting_abr"), control: abrSwitch)
        let srRow = makeSwitchRow(title: LiveSportL10n("live_sport_super_resolution"), control: superResolutionSwitch)
        let sharpenRow = makeSwitchRow(title: LiveSportL10n("live_sport_sharpen"), control: sharpenSwitch)
        self.abrRow = abrRow

        [abrRow, srRow, sharpenRow].forEach { row in
            switchesStackView.addArrangedSubview(row)
            row.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
    }

    private func setupFooter() {
        let spacer = UIView()
        spacer.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
        contentStackView.addArrangedSubview(spacer)

        let footerView = UIView()
        contentStackView.addArrangedSubview(footerView)

        saveButton.setTitle(LiveSportL10n("live_sport_save"), for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        saveButton.layer.cornerRadius = 8
        saveButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        saveButton.layer.shadowOpacity = 1
        saveButton.layer.shadowRadius = 1
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        footerView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func bindActions() {
        closeButton.addAction(UIAction { [weak self] _ in
            self?.onClose?()
        }, for: .touchUpInside)

        protocolRowButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.setProtocolMenuVisible(!self.isProtocolListExpanded, animated: true)
        }, for: .touchUpInside)
        protocolMenuBackdrop.addAction(UIAction { [weak self] _ in
            self?.setProtocolMenuVisible(false, animated: true)
        }, for: .touchUpInside)

        abrSwitch.addAction(UIAction { [weak self] _ in
            self?.pendingSetting.enableABR = self?.abrSwitch.isOn ?? false
        }, for: .valueChanged)

        superResolutionSwitch.addAction(UIAction { [weak self] _ in
            self?.pendingSetting.enableSuperResolution = self?.superResolutionSwitch.isOn ?? false
        }, for: .valueChanged)

        sharpenSwitch.addAction(UIAction { [weak self] _ in
            self?.pendingSetting.enableSharpen = self?.sharpenSwitch.isOn ?? false
        }, for: .valueChanged)

        saveButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.setProtocolMenuVisible(false, animated: false)
            self.onSave?(self.pendingSetting)
        }, for: .touchUpInside)
    }

    private func makeSwitchRow(title: String, control: UISwitch) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        container.addSubview(label)
        container.addSubview(control)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        control.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return container
    }

    private func makeProtocolOptionButton(streamProtocol: StreamProtocol) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = protocolOptionButtons.count
        button.setTitle(streamProtocol.displayName, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.setTitleColor(UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        button.addAction(UIAction { [weak self] _ in
            self?.handleSelectProtocol(streamProtocol)
        }, for: .touchUpInside)
        return button
    }

    private func handleSelectProtocol(_ streamProtocol: StreamProtocol) {
        pendingSetting.streamProtocol = streamProtocol
        updateProtocolRow()
        updateProtocolOptions()
        handleProtocolDependency()
        setProtocolMenuVisible(false, animated: true)
    }

    private func handleProtocolDependency() {
        let abrEnabled = pendingSetting.streamProtocol == .flv || pendingSetting.streamProtocol == .flvLowLatency
        if !abrEnabled {
            pendingSetting.enableABR = false
            abrSwitch.isOn = false
        }
        abrRow?.isHidden = !abrEnabled
    }

    private func updateProtocolRow() {
        protocolValueLabel.text = pendingSetting.streamProtocol.displayName
    }

    private func updateProtocolOptions() {
        for (index, button) in protocolOptionButtons.enumerated() {
            let proto = StreamProtocol.allCases[index]
            let isSelected = proto == pendingSetting.streamProtocol
            button.backgroundColor = isSelected
                ? UIColor(red: 245.0 / 255.0, green: 247.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
                : .white
            button.setTitleColor(isSelected
                                 ? UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
                                 : UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0),
                                 for: .normal)
        }
    }

    private func updateProtocolMenuLayout() {
        let menuTopFrame = convert(protocolRowButton.bounds, from: protocolRowButton)
        let saveFrame = convert(saveButton.bounds, from: saveButton)
        let availableHeight = max(saveFrame.minY - menuTopFrame.maxY - 12.0, 40.0)
        currentProtocolMenuHeight = min(protocolMenuContentHeight, availableHeight)
        protocolMenuHeightConstraint?.update(offset: currentProtocolMenuHeight)
        protocolMenuScrollView.isScrollEnabled = protocolMenuContentHeight > availableHeight
    }
}
