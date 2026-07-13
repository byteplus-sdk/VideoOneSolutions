// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Portrait gift panel: a dimmed mask plus a bottom sheet that slides up and
/// hosts the gift content row. Landscape reuses `LiveSportGiftContentView`
/// directly inside the shared side-panel container instead of this view.
public final class LiveSportGiftPanel: UIView {

    public var onSend: ((LiveSportGift) -> Void)?
    public var onDismiss: (() -> Void)?

    private let maskButton = UIControl()
    private let sheetView = UIView()
    private let contentView = LiveSportGiftContentView()
    private var sheetBottomConstraint: Constraint?
    private var sheetHeightConstraint: Constraint?
    private var sheetHeight: CGFloat = 0

    /// Default portrait sheet height; the catalog collection view scrolls
    /// internally when the catalog is taller than this.
    private let defaultSheetHeight: CGFloat = 300

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func present(in parent: UIView) {
        parent.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Use a fixed default sheet height (capped so a short screen still
        // leaves room above the sheet); the catalog collection view scrolls
        // internally when the catalog is taller. Set the real height before any
        // layout pass so the placeholder height never forces an impossible
        // layout of the title + collection.
        let maxHeight = parent.bounds.height * 0.7
        sheetHeight = min(defaultSheetHeight, maxHeight)
        sheetHeightConstraint?.update(offset: sheetHeight)

        // Start fully off-screen, then slide up.
        maskButton.alpha = 0
        sheetBottomConstraint?.update(offset: sheetHeight)
        layoutIfNeeded()

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.maskButton.alpha = 1
            self.sheetBottomConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }
    }

    public func dismiss(animated: Bool) {
        let finish: () -> Void = {
            self.removeFromSuperview()
        }
        guard animated else {
            finish()
            return
        }
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
            self.maskButton.alpha = 0
            self.sheetBottomConstraint?.update(offset: self.sheetHeight)
            self.layoutIfNeeded()
        }, completion: { _ in
            finish()
        })
    }

    private func setupSubviews() {
        addSubview(maskButton)
        maskButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        maskButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        maskButton.addAction(UIAction { [weak self] _ in
            self?.onDismiss?()
        }, for: .touchUpInside)

        sheetView.backgroundColor = UIColor(red: 6.0 / 255.0, green: 18.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
        sheetView.layer.cornerRadius = 16
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        addSubview(sheetView)
        sheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            self.sheetHeightConstraint = make.height.equalTo(defaultSheetHeight).constraint
            self.sheetBottomConstraint = make.bottom.equalToSuperview().offset(defaultSheetHeight).constraint
        }

        sheetView.addSubview(contentView)
        contentView.onSend = { [weak self] gift in
            self?.onSend?(gift)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
