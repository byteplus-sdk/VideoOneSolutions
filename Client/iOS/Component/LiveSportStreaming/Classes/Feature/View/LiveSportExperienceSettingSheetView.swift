// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Bottom sheet matching the "Live Watch Setting" design used by the
/// live-experience entry: a stream URL input card with clear/paste actions,
/// a lightweight strategy surface (conditional FLV low latency / super
/// resolution / sharpen) and a blue "Save" button.
public final class LiveSportExperienceSettingSheetView: UIView, UITextViewDelegate, UIGestureRecognizerDelegate {

    public var onClose: (() -> Void)?
    public var onSave: ((LiveSetting) -> Void)?

    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let urlTextView = UITextView()
    private let urlPlaceholderLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let pasteButton = UIButton(type: .system)
    private let urlWarningLabel = UILabel()

    private let flvLowLatencySwitch = UISwitch()
    private let superResolutionSwitch = UISwitch()
    private let sharpenSwitch = UISwitch()
    private let footerView = UIView()
    private let saveButton = UIButton(type: .system)
    private let flvLowLatencyRow = UIView()
    private let flvLowLatencySeparator = UIView()
    private let superResolutionRow = UIView()
    private let superResolutionSeparator = UIView()
    private let sharpenRow = UIView()
    private lazy var blankTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleBlankTap))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    private var pendingSetting = LiveSetting()
    private var scrollContentHeightConstraint: Constraint?
    private var strategyCardHeightConstraint: Constraint?
    private var closeBtnTrailingConstraint: Constraint?
    private weak var activeEditorView: UIView?

    private let titleColor = UIColor(red: 29.0 / 255.0, green: 33.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
    private let bodyColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    private let switchOnColor = UIColor(red: 28.0 / 255.0, green: 178.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        bindActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollContentHeightIfNeeded()
    }

    public func configure(setting: LiveSetting) {
        pendingSetting = setting
        superResolutionSwitch.isOn = setting.enableSuperResolution
        sharpenSwitch.isOn = setting.enableSharpen
        urlTextView.text = setting.customStreamURL
        updatePlaceholderVisibility()
        refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    public func applyLandscapeSidePanelStyle() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        scrollContentHeightConstraint?.deactivate()
        closeBtnTrailingConstraint?.update(offset: -20)
    }

    public func activeEditorFrame(in view: UIView) -> CGRect? {
        guard let activeEditorView else { return nil }
        return activeEditorView.convert(activeEditorView.bounds, to: view)
    }

    public var isEditingInput: Bool {
        activeEditorView != nil
    }

    // MARK: - Setup

    private func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        addGestureRecognizer(blankTapGestureRecognizer)

        addSubview(headerView)
        addSubview(scrollView)
        addSubview(footerView)

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
            self.scrollContentHeightConstraint = make.height.equalTo(0).constraint
        }

        footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        scrollView.addSubview(scrollContentView)
        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        scrollContentView.addSubview(contentStackView)
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }

        setupHeader()

        let urlSectionLabel = makeSectionLabel(LiveSportL10n("live_sport_experience_url_label"))
        contentStackView.addArrangedSubview(urlSectionLabel)
        contentStackView.setCustomSpacing(8, after: urlSectionLabel)
        contentStackView.addArrangedSubview(makeURLCard())
        contentStackView.addArrangedSubview(urlWarningLabel)
        contentStackView.addArrangedSubview(makeSectionLabel(LiveSportL10n("live_sport_experience_strategy")))
        contentStackView.addArrangedSubview(makeStrategyCard())
        setupFooter()

        urlWarningLabel.textColor = .systemRed
        urlWarningLabel.font = UIFont.systemFont(ofSize: 12)
        urlWarningLabel.text = LiveSportL10n("live_sport_vod_url_warning")
        urlWarningLabel.numberOfLines = 0
        urlWarningLabel.isHidden = true
    }

    private func updateScrollContentHeightIfNeeded() {
        let availableWidth = scrollView.bounds.width - 32
        guard availableWidth > 0 else { return }

        let targetSize = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = contentStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        scrollContentHeightConstraint?.update(offset: ceil(fittedSize.height))
    }

    private func setupHeader() {
        titleLabel.text = LiveSportL10n("live_sport_watch_setting_title")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = titleColor

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
            closeBtnTrailingConstraint = make.trailing.equalToSuperview().constraint
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 128.0 / 255.0, green: 131.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        return label
    }

    private func makeURLCard() -> UIView {
        let inputBox = UIView()
        inputBox.backgroundColor = UIColor(red: 22.0 / 255.0, green: 24.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.05)
        inputBox.layer.cornerRadius = 8
        inputBox.snp.makeConstraints { make in
            make.height.equalTo(124)
        }

        urlTextView.backgroundColor = .clear
        urlTextView.font = UIFont.systemFont(ofSize: 14)
        urlTextView.textColor = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
        urlTextView.autocapitalizationType = .none
        urlTextView.autocorrectionType = .no
        urlTextView.keyboardType = .URL
        urlTextView.delegate = self
        urlTextView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        inputBox.addSubview(urlTextView)
        urlTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-44)
        }

        urlPlaceholderLabel.text = LiveSportL10n("live_sport_experience_url_placeholder")
        urlPlaceholderLabel.font = UIFont.systemFont(ofSize: 14)
        urlPlaceholderLabel.textColor = UIColor(red: 22.0 / 255.0, green: 24.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.3)
        inputBox.addSubview(urlPlaceholderLabel)
        urlPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(urlTextView).offset(4)
            make.leading.equalTo(urlTextView).offset(4)
        }

        configurePill(clearButton, title: LiveSportL10n("live_sport_experience_clear"))
        clearButton.addAction(UIAction { [weak self] _ in
            self?.handleClear()
        }, for: .touchUpInside)
        inputBox.addSubview(clearButton)

        configurePill(pasteButton, title: LiveSportL10n("live_sport_experience_paste"))
        pasteButton.addAction(UIAction { [weak self] _ in
            self?.handlePaste()
        }, for: .touchUpInside)
        inputBox.addSubview(pasteButton)

        pasteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(24)
        }
        clearButton.snp.makeConstraints { make in
            make.trailing.equalTo(pasteButton.snp.leading).offset(-8)
            make.centerY.equalTo(pasteButton)
            make.height.equalTo(24)
        }
        return inputBox
    }

    private func configurePill(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor(red: 22.0 / 255.0, green: 24.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.6), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    }

    private func makeStrategyCard() -> UIView {
        let card = UIView()
        card.snp.makeConstraints { make in
            self.strategyCardHeightConstraint = make.height.equalTo(168).constraint
        }

        let inner = UIStackView()
        inner.axis = .vertical
        inner.alignment = .fill
        card.addSubview(inner)
        inner.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        flvLowLatencySwitch.onTintColor = switchOnColor
        superResolutionSwitch.onTintColor = switchOnColor
        sharpenSwitch.onTintColor = switchOnColor

        flvLowLatencySwitch.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.pendingSetting.streamProtocol = self.flvLowLatencySwitch.isOn ? .flvLowLatency : .flv
        }, for: .valueChanged)
        superResolutionSwitch.addAction(UIAction { [weak self] _ in
            self?.pendingSetting.enableSuperResolution = self?.superResolutionSwitch.isOn ?? false
        }, for: .valueChanged)
        sharpenSwitch.addAction(UIAction { [weak self] _ in
            self?.pendingSetting.enableSharpen = self?.sharpenSwitch.isOn ?? false
        }, for: .valueChanged)

        configureSeparator(flvLowLatencySeparator)
        configureSeparator(superResolutionSeparator)
        configureStrategyRow(flvLowLatencyRow,
                             title: LiveSportL10n("live_sport_protocol_flv_low_latency"),
                             control: flvLowLatencySwitch)
        configureStrategyRow(superResolutionRow,
                             title: LiveSportL10n("live_sport_super_resolution"),
                             control: superResolutionSwitch)
        configureStrategyRow(sharpenRow,
                             title: LiveSportL10n("live_sport_sharpen"),
                             control: sharpenSwitch)

        inner.addArrangedSubview(flvLowLatencyRow)
        inner.addArrangedSubview(flvLowLatencySeparator)
        inner.addArrangedSubview(superResolutionRow)
        inner.addArrangedSubview(superResolutionSeparator)
        inner.addArrangedSubview(sharpenRow)
        return card
    }

    private func configureStrategyRow(_ row: UIView, title: String, control: UISwitch) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = bodyColor
        row.addSubview(label)
        row.addSubview(control)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        control.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
        }
        row.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    private func configureSeparator(_ separator: UIView) {
        separator.backgroundColor = UIColor(red: 22.0 / 255.0, green: 24.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.05)
        separator.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
    }

    private func setupFooter() {
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
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(2)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    private func bindActions() {
        closeButton.addAction(UIAction { [weak self] _ in
            self?.onClose?()
        }, for: .touchUpInside)

        saveButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.endEditing(true)
            self.pendingSetting.customStreamURL = self.urlTextView.text ?? ""
            guard let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: self.pendingSetting) else {
                self.refreshDerivedSettingState(showWarningForInvalidURL: true)
                return
            }
            self.pendingSetting = resolvedSetting
            self.refreshDerivedSettingState(showWarningForInvalidURL: false)
            self.onSave?(resolvedSetting)
        }, for: .touchUpInside)
    }

    // MARK: - URL helpers

    private func handleClear() {
        urlTextView.text = ""
        pendingSetting.customStreamURL = ""
        updatePlaceholderVisibility()
        refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    private func handlePaste() {
        guard let pasted = UIPasteboard.general.string else { return }
        urlTextView.text = pasted
        pendingSetting.customStreamURL = pasted
        updatePlaceholderVisibility()
        refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    private func updatePlaceholderVisibility() {
        urlPlaceholderLabel.isHidden = !(urlTextView.text ?? "").isEmpty
    }

    private func refreshDerivedSettingState(showWarningForInvalidURL: Bool) {
        let text = urlTextView.text ?? ""
        pendingSetting.customStreamURL = text
        let inferredPlayback = LiveSportSettingManager.shared.inferPlayback(from: text)

        if let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: pendingSetting) {
            applyResolvedExperienceState(resolvedSetting, inferredPlayback: inferredPlayback)
            urlWarningLabel.isHidden = true
            return
        }

        clearLowLatencySelection()
        let hasInput = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        urlWarningLabel.isHidden = !(showWarningForInvalidURL && hasInput)
    }

    private func setLowLatencyRowHidden(_ hidden: Bool) {
        flvLowLatencyRow.isHidden = hidden
        flvLowLatencySeparator.isHidden = hidden
        let visibleRowCount = hidden ? 2 : 3
        let separatorCount = hidden ? 1 : 2
        let rowHeight = CGFloat(visibleRowCount) * 56.0
        let separatorHeight = CGFloat(separatorCount) * (1.0 / UIScreen.main.scale)
        strategyCardHeightConstraint?.update(offset: rowHeight + separatorHeight)
    }

    private func clearLowLatencySelection() {
        pendingSetting.streamProtocol = .flv
        flvLowLatencySwitch.isOn = false
        setLowLatencyRowHidden(true)
    }

    private func applyResolvedExperienceState(_ resolvedSetting: LiveSetting,
                                             inferredPlayback: LiveSportSettingManager.InferredPlayback?) {
        pendingSetting.streamProtocol = resolvedSetting.streamProtocol
        pendingSetting.enableABR = resolvedSetting.enableABR
        let supportsLowLatency = inferredPlayback?.supportsLowLatencyToggle ?? false
        if supportsLowLatency {
            flvLowLatencySwitch.isOn = resolvedSetting.streamProtocol == .flvLowLatency
            setLowLatencyRowHidden(false)
        } else {
            clearLowLatencySelection()
            pendingSetting.streamProtocol = resolvedSetting.streamProtocol
            pendingSetting.enableABR = resolvedSetting.enableABR
        }
    }

    // MARK: - UITextViewDelegate

    @objc
    private func handleBlankTap() {
        guard isEditingInput else { return }
        endEditing(true)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === blankTapGestureRecognizer else { return true }
        guard let touchedView = touch.view else { return false }
        if touchedView is UIControl || touchedView is UITextView {
            return false
        }

        var currentView: UIView? = touchedView
        while let view = currentView {
            if view is UIControl || view is UITextView {
                return false
            }
            currentView = view.superview
        }
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        pendingSetting.customStreamURL = textView.text ?? ""
        updatePlaceholderVisibility()
        refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        activeEditorView = textView
        urlWarningLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if activeEditorView === textView {
            activeEditorView = nil
        }
        pendingSetting.customStreamURL = textView.text ?? ""
        refreshDerivedSettingState(showWarningForInvalidURL: true)
    }
}
