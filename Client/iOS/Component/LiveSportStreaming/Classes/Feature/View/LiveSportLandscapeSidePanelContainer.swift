// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Generic right-side slide-in container used in landscape to host the
/// multi-camera, quality and setting panels with a shared slide animation.
public final class LiveSportLandscapeSidePanelContainer: UIView {

    public var onDismiss: (() -> Void)?

    private let backdropButton = UIControl()
    private let panelHostView = UIView()
    private var panelWidthConstraint: Constraint?
    private weak var contentView: UIView?
    private var panelWidth: CGFloat = 247

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var isPresenting: Bool {
        return !isHidden && contentView != nil
    }

    /// Shows the given content view as a right-side panel sliding in from the
    /// trailing edge. Any previous content is removed first.
    public func show(content: UIView, width: CGFloat) {
        contentView?.removeFromSuperview()
        contentView = content
        panelWidth = width + safeAreaInsets.right
        panelWidthConstraint?.update(offset: panelWidth)
        panelHostView.backgroundColor = content.backgroundColor ?? .white

        panelHostView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        isHidden = false
        layoutIfNeeded()

        backdropButton.alpha = 0
        panelHostView.transform = CGAffineTransform(translationX: panelWidth, y: 0)
        UIView.animate(withDuration: 0.28,
                       delay: 0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.backdropButton.alpha = 1
            self.panelHostView.transform = .identity
        }
    }

    public func hide(animated: Bool, completion: (() -> Void)? = nil) {
        guard !isHidden else {
            completion?()
            return
        }
        let finish: () -> Void = {
            self.isHidden = true
            self.contentView?.removeFromSuperview()
            self.contentView = nil
            completion?()
        }
        let changes = {
            self.backdropButton.alpha = 0
            self.panelHostView.transform = CGAffineTransform(translationX: self.panelWidth, y: 0)
        }
        if animated {
            UIView.animate(withDuration: 0.24,
                           delay: 0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: changes) { _ in
                finish()
            }
        } else {
            changes()
            finish()
        }
    }

    private func setupSubviews() {
        isHidden = true

        addSubview(backdropButton)
        backdropButton.backgroundColor = UIColor.black.withAlphaComponent(0.001)
        backdropButton.alpha = 0
        backdropButton.addAction(UIAction { [weak self] _ in
            self?.onDismiss?()
        }, for: .touchUpInside)
        backdropButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(panelHostView)
        panelHostView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            self.panelWidthConstraint = make.width.equalTo(panelWidth).constraint
        }
    }
}
