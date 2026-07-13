// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public protocol LiveInteractionViewDelegate: AnyObject {
    func interactionViewDidTapLike(_ view: LiveInteractionView)
    func interactionViewDidTapGift(_ view: LiveInteractionView)
    func interactionView(_ view: LiveInteractionView, didSubmit text: String)
}

/// Bottom row containing chat input, like and gift buttons.
public final class LiveInteractionView: UIView {

    public weak var delegate: LiveInteractionViewDelegate?

    private let inputField = UITextField()
    private let likeButton = UIButton(type: .system)
    private let giftButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        layer.cornerRadius = 22

        inputField.placeholder = LiveSportL10n("live_sport_say_something")
        inputField.attributedPlaceholder = NSAttributedString(
            string: LiveSportL10n("live_sport_say_something"),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        inputField.textColor = .white
        inputField.returnKeyType = .send
        inputField.delegate = self

        likeButton.setTitle(LiveSportL10n("live_sport_like"), for: .normal)
        likeButton.tintColor = .systemPink
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        likeButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.interactionViewDidTapLike(self)
        }, for: .touchUpInside)

        giftButton.setTitle(LiveSportL10n("live_sport_send_gift"), for: .normal)
        giftButton.tintColor = .systemYellow
        giftButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        giftButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.interactionViewDidTapGift(self)
        }, for: .touchUpInside)

        addSubview(inputField)
        addSubview(giftButton)
        addSubview(likeButton)

        likeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
        }
        giftButton.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
        }
        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(giftButton.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LiveInteractionView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            delegate?.interactionView(self, didSubmit: text)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
}
