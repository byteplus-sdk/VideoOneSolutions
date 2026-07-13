// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// "Live Experience" page: a stream URL input card with clear/paste actions,
/// a lightweight strategy surface (conditional FLV low latency / super
/// resolution / sharpen) and a "Watch Now" button that saves the setting and
/// opens the watch page.
public final class LiveSportSettingViewController: UIViewController, UITextViewDelegate {

    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let urlTextView = UITextView()
    private let urlPlaceholderLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let pasteButton = UIButton(type: .system)
    private let urlWarningLabel = UILabel()

    private let flvLowLatencySwitch = UISwitch()
    private let superResolutionSwitch = UISwitch()
    private let sharpenSwitch = UISwitch()
    private let flvLowLatencyRow = UIView()
    private let flvLowLatencySeparator = UIView()
    private let superResolutionRow = UIView()
    private let superResolutionSeparator = UIView()
    private let sharpenRow = UIView()

    private let watchButton = UIButton(type: .system)

    private var pendingSetting: LiveSetting = LiveSportSettingManager.shared.currentSetting

    private let backgroundColorValue = UIColor(red: 246.0 / 255.0, green: 248.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    private let titleColor = UIColor(red: 2.0 / 255.0, green: 8.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    private let switchOnColor = UIColor(red: 28.0 / 255.0, green: 178.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColorValue
        setupHeader()
        setupSubviews()
        bindCurrentSetting()
        setupKeyboardDismissGesture()
    }

    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboardTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    private func handleDismissKeyboardTap() {
        view.endEditing(true)
    }

    // MARK: - Setup

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = titleColor
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        titleLabel.text = LiveSportL10n("live_sport_experience_title")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = titleColor
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let watchContainer = UIView()
        view.addSubview(watchContainer)
        watchContainer.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        watchButton.setTitle(LiveSportL10n("live_sport_experience_watch_now"), for: .normal)
        watchButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        watchButton.setTitleColor(.white, for: .normal)
        watchButton.backgroundColor = UIColor(red: 22.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        watchButton.layer.cornerRadius = 8
        watchButton.addAction(UIAction { [weak self] _ in
            self?.handleWatch()
        }, for: .touchUpInside)
        watchContainer.addSubview(watchButton)
        watchButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(48)
        }

        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }

        stack.addArrangedSubview(makeSectionLabel(LiveSportL10n("live_sport_experience_url_label")))
        stack.addArrangedSubview(makeURLCard())
        stack.addArrangedSubview(urlWarningLabel)
        stack.addArrangedSubview(makeSectionLabel(LiveSportL10n("live_sport_experience_strategy")))
        stack.addArrangedSubview(makeStrategyCard())

        urlWarningLabel.textColor = .systemRed
        urlWarningLabel.font = UIFont.systemFont(ofSize: 12)
        urlWarningLabel.text = LiveSportL10n("live_sport_vod_url_warning")
        urlWarningLabel.numberOfLines = 0
        urlWarningLabel.isHidden = true
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 128.0 / 255.0, green: 131.0 / 255.0, blue: 138.0 / 255.0, alpha: 1.0)
        return label
    }

    private func makeURLCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8

        let inputBox = UIView()
        inputBox.backgroundColor = UIColor(red: 22.0 / 255.0, green: 24.0 / 255.0, blue: 35.0 / 255.0, alpha: 0.05)
        inputBox.layer.cornerRadius = 8
        card.addSubview(inputBox)
        inputBox.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(124)
        }

        urlTextView.backgroundColor = .clear
        urlTextView.font = UIFont.systemFont(ofSize: 14)
        urlTextView.textColor = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
        urlTextView.autocapitalizationType = .none
        urlTextView.autocorrectionType = .no
        urlTextView.keyboardType = .URL
        urlTextView.delegate = self
        urlTextView.textContainer.lineBreakMode = .byCharWrapping
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
        return card
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
        card.backgroundColor = .white
        card.layer.cornerRadius = 8

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
        label.textColor = titleColor
        row.addSubview(label)
        row.addSubview(control)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        control.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
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

    // MARK: - Binding

    private func bindCurrentSetting() {
        pendingSetting = LiveSportSettingManager.shared.currentSetting
        superResolutionSwitch.isOn = pendingSetting.enableSuperResolution
        sharpenSwitch.isOn = pendingSetting.enableSharpen
        urlTextView.text = pendingSetting.customStreamURL
        updatePlaceholderVisibility()
          refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    private func updatePlaceholderVisibility() {
        urlPlaceholderLabel.isHidden = !(urlTextView.text ?? "").isEmpty
    }

    private func hideURLWarning() {
        urlWarningLabel.isHidden = true
    }

    @discardableResult
    private func validateURLInputAndUpdateWarning() -> Bool {
        refreshDerivedSettingState(showWarningForInvalidURL: true)
        return urlWarningLabel.isHidden
    }

    // MARK: - Actions

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

    private func refreshDerivedSettingState(showWarningForInvalidURL: Bool) {
        let text = urlTextView.text ?? ""
        pendingSetting.customStreamURL = text
        let inferredPlayback = LiveSportSettingManager.shared.inferPlayback(from: text)

        if let resolved = LiveSportSettingManager.shared.resolveExperienceSetting(from: pendingSetting) {
            applyResolvedExperienceState(resolved, inferredPlayback: inferredPlayback)
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
    }

    private func clearLowLatencySelection() {
        pendingSetting.streamProtocol = .flv
        flvLowLatencySwitch.isOn = false
        setLowLatencyRowHidden(true)
    }

    private func applyResolvedExperienceState(_ resolved: LiveSetting,
                                             inferredPlayback: LiveSportSettingManager.InferredPlayback?) {
        pendingSetting.streamProtocol = resolved.streamProtocol
        pendingSetting.enableABR = resolved.enableABR
        let supportsLowLatency = inferredPlayback?.supportsLowLatencyToggle ?? false
        if supportsLowLatency {
            flvLowLatencySwitch.isOn = resolved.streamProtocol == .flvLowLatency
            setLowLatencyRowHidden(false)
        } else {
            clearLowLatencySelection()
            pendingSetting.streamProtocol = resolved.streamProtocol
            pendingSetting.enableABR = resolved.enableABR
        }
    }

    private func handleWatch() {
        view.endEditing(true)
        guard let resolvedSetting = LiveSportSettingManager.shared.resolveExperienceSetting(from: pendingSetting) else {
            _ = validateURLInputAndUpdateWarning()
            return
        }
        LiveSportSettingManager.shared.update(setting: resolvedSetting)
        navigationController?.pushViewController(LiveSportWatchViewController(mode: .experience), animated: true)
    }

    // MARK: - UITextViewDelegate

    public func textViewDidBeginEditing(_ textView: UITextView) {
        hideURLWarning()
    }

    public func textViewDidChange(_ textView: UITextView) {
        pendingSetting.customStreamURL = textView.text ?? ""
        updatePlaceholderVisibility()
        refreshDerivedSettingState(showWarningForInvalidURL: false)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        pendingSetting.customStreamURL = textView.text ?? ""
        _ = validateURLInputAndUpdateWarning()
    }
}
