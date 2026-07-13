// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportWatchInputBarView: UIView {

    public var onSubmitText: ((String) -> Void)?
    public var onGiftTap: (() -> Void)?
    public var onMoreTap: (() -> Void)?
    public var isInputEditing: Bool { inputField.isFirstResponder }

    private let inputContainerView = UIView()
    private let inputField = UITextField()
    private let buttonsContainerView = UIView()
    private let giftButton = UIButton(type: .system)
    private let moreButton = UIButton(type: .system)
    private var buttonsContainerWidthConstraint: Constraint?
    private var inputContainerTrailingConstraint: Constraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func focusInput() {
        inputField.becomeFirstResponder()
    }

    public func dismissInput() {
        inputField.resignFirstResponder()
    }

    /// Center of the gift button converted into the given coordinate space, used
    /// as the start point of the gift float-up animation.
    public func giftButtonCenter(in coordinateSpace: UICoordinateSpace) -> CGPoint {
        let center = CGPoint(x: giftButton.bounds.midX, y: giftButton.bounds.midY)
        return giftButton.convert(center, to: coordinateSpace)
    }

    public func setAccessoryButtonsHidden(_ hidden: Bool, animated: Bool) {
        buttonsContainerWidthConstraint?.update(offset: hidden ? 0 : 84)
        inputContainerTrailingConstraint?.update(offset: hidden ? 0 : -12)
        let changes = {
            self.buttonsContainerView.alpha = hidden ? 0.0 : 1.0
            self.buttonsContainerView.isUserInteractionEnabled = !hidden
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: changes)
        } else {
            changes()
        }
    }

    private func setupSubviews() {
        addSubview(inputContainerView)
        addSubview(buttonsContainerView)

        inputContainerView.backgroundColor = UIColor(red: 0.0, green: 22.0 / 255.0, blue: 49.0 / 255.0, alpha: 0.72)
        inputContainerView.layer.cornerRadius = 18
        inputContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            self.inputContainerTrailingConstraint = make.trailing.equalTo(buttonsContainerView.snp.leading).offset(-12).constraint
            make.height.equalTo(36)
        }

        inputField.delegate = self
        inputField.returnKeyType = .send
        inputField.textColor = .white
        inputField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        inputField.attributedPlaceholder = NSAttributedString(
            string: LiveSportL10n("live_sport_say_something"),
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]
        )
        inputContainerView.addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        buttonsContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            self.buttonsContainerWidthConstraint = make.width.equalTo(84).constraint
        }
        buttonsContainerView.addSubview(giftButton)
        buttonsContainerView.addSubview(moreButton)

        configureCircleButton(giftButton, image: LiveSportImage(named: "sport_gift_icon")?.withRenderingMode(.alwaysOriginal))
        giftButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(36)
        }
        giftButton.addAction(UIAction { [weak self] _ in
            self?.onGiftTap?()
        }, for: .touchUpInside)

        configureCircleButton(moreButton, image: UIImage(systemName: "gearshape.fill"))
        moreButton.snp.makeConstraints { make in
            make.leading.equalTo(giftButton.snp.trailing).offset(12)
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(36)
        }
        moreButton.addAction(UIAction { [weak self] _ in
            self?.onMoreTap?()
        }, for: .touchUpInside)
    }

    private func configureCircleButton(_ button: UIButton, image: UIImage?) {
        button.backgroundColor = UIColor(red: 0.0, green: 22.0 / 255.0, blue: 49.0 / 255.0, alpha: 0.72)
        button.layer.cornerRadius = 18
        button.tintColor = .white
        button.setImage(image, for: .normal)
    }
}

extension LiveSportWatchInputBarView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        onSubmitText?(text)
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
