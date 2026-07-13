// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Bottom-sheet container hosting `LiveSportExperienceSettingSheetView`, used by
/// the live-experience entry's "settings" action.
public final class LiveSportExperienceSettingSheetViewController: UIViewController {

    private let keyboardGap: CGFloat = 12

    public var onSave: ((LiveSetting) -> Void)?

    private let dimmedView = UIControl()
    private let sheetView = LiveSportExperienceSettingSheetView()
    private let initialSetting: LiveSetting
    private var isDismissingSheet = false
    private var hasPresentedSheet = false
    private var sheetHiddenOffset: CGFloat = 0
    private var sheetBottomConstraint: Constraint?

    public init(setting: LiveSetting) {
        self.initialSetting = setting
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        sheetView.isHidden = true
        setupSubviews()
        bindActions()
        observeKeyboardNotifications()
        sheetView.configure(setting: initialSetting)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheetIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSubviews() {
        view.backgroundColor = .clear

        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.36)
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(sheetView)
        sheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            self.sheetBottomConstraint = make.bottom.equalToSuperview().constraint
        }
    }

    private func bindActions() {
        dimmedView.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if self.sheetView.isEditingInput {
                self.view.endEditing(true)
                return
            }
            self.dismissSheet(animated: true, completion: nil)
        }, for: .touchUpInside)

        sheetView.onClose = { [weak self] in
            self?.dismissSheet(animated: true, completion: nil)
        }

        sheetView.onSave = { [weak self] setting in
            self?.dismissSheet(animated: true, completion: {
                self?.onSave?(setting)
            })
        }
    }

    private func presentSheetIfNeeded() {
        guard !hasPresentedSheet else { return }
        hasPresentedSheet = true
        view.layoutIfNeeded()
        sheetHiddenOffset = measuredSheetHeight()
        sheetView.transform = CGAffineTransform(translationX: 0, y: sheetHiddenOffset)
        sheetView.isHidden = false
        UIView.animate(withDuration: 0.32,
                       delay: 0,
                       usingSpringWithDamping: 0.92,
                       initialSpringVelocity: 0.12,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: {
            self.dimmedView.alpha = 1
            self.sheetView.transform = .identity
        })
    }

    private func dismissSheet(animated: Bool, completion: (() -> Void)?) {
        guard !isDismissingSheet else { return }
        isDismissingSheet = true

        let finish = { [weak self] in
            self?.dismiss(animated: false, completion: completion)
        }

        guard animated else {
            finish()
            return
        }

        UIView.animate(withDuration: 0.24,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            self.dimmedView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0,
                                                         y: max(self.sheetHiddenOffset, self.measuredSheetHeight()))
        }, completion: { _ in
            finish()
        })
    }

    private func measuredSheetHeight() -> CGFloat {
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = sheetView.systemLayoutSizeFitting(targetSize,
                                                     withHorizontalFittingPriority: .required,
                                                     verticalFittingPriority: .fittingSizeLevel)
        return ceil(size.height)
    }

    // MARK: - Keyboard

    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc
    private func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let isHiding = notification.name == UIResponder.keyboardWillHideNotification
        let bottomInset: CGFloat
        if isHiding {
            bottomInset = 0
        } else {
            view.layoutIfNeeded()
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
            let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
            guard let activeEditorFrame = sheetView.activeEditorFrame(in: view) else {
                updateSheetBottomInset(0, duration: duration, curveRaw: curveRaw)
                return
            }

            let requiredGap = activeEditorFrame.maxY + keyboardGap - convertedKeyboardFrame.minY
            bottomInset = max(requiredGap, 0)
        }

        updateSheetBottomInset(bottomInset, duration: duration, curveRaw: curveRaw)
    }

    private func updateSheetBottomInset(_ bottomInset: CGFloat,
                                        duration: TimeInterval,
                                        curveRaw: UInt) {
        sheetBottomConstraint?.update(offset: -bottomInset)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [UIView.AnimationOptions(rawValue: curveRaw << 16), .beginFromCurrentState]) {
            self.view.layoutIfNeeded()
        }
    }
}
