// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Wrapper view that hosts the underlying player render view and a transparent
/// gesture overlay for single/double tap interactions. Tap handlers forward the
/// tap location so callers can position like effects at the finger.
public final class LivePlayerControlView: UIView {

    public var onDoubleTap: ((CGPoint) -> Void)?
    public var onSingleTap: ((CGPoint) -> Void)?
    public var onLeftControlTap: (() -> Void)?
    public var onRightControlTap: (() -> Void)?

    private let leftControlButton = UIButton(type: .custom)
    private let rightControlButton = UIButton(type: .custom)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        let single = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        single.numberOfTapsRequired = 1
        let double = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        double.numberOfTapsRequired = 2
        single.require(toFail: double)
        addGestureRecognizer(single)
        addGestureRecognizer(double)

        setupControlButtons()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func attach(renderView: UIView) {
        addSubview(renderView)
        renderView.translatesAutoresizingMaskIntoConstraints = false
        renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sendSubviewToBack(renderView)
    }

    public func setLeftControlImage(_ image: UIImage?) {
        leftControlButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    public func setRightControlImage(_ image: UIImage?) {
        rightControlButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    public func setRightControlImageTransform(_ transform: CGAffineTransform) {
        rightControlButton.transform = transform
    }

    /// Hides the built-in play/rotate buttons when the landscape controls layer
    /// takes over those interactions.
    public func setControlButtonsHidden(_ hidden: Bool) {
        leftControlButton.isHidden = hidden
        rightControlButton.isHidden = hidden
        leftControlButton.isUserInteractionEnabled = !hidden
        rightControlButton.isUserInteractionEnabled = !hidden
    }

    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        onSingleTap?(gesture.location(in: self))
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        onDoubleTap?(gesture.location(in: self))
    }

    private func setupControlButtons() {
        addSubview(leftControlButton)
        addSubview(rightControlButton)

        leftControlButton.adjustsImageWhenHighlighted = false
        rightControlButton.adjustsImageWhenHighlighted = false

        leftControlButton.addAction(UIAction { [weak self] _ in
            self?.onLeftControlTap?()
        }, for: .touchUpInside)
        rightControlButton.addAction(UIAction { [weak self] _ in
            self?.onRightControlTap?()
        }, for: .touchUpInside)

        leftControlButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }

        rightControlButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }
    }
}
