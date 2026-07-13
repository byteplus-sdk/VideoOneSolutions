// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportWatchSettingSheetViewController: UIViewController {

    public var onSave: ((LiveSetting) -> Void)?

    private let dimmedView = UIControl()
    private let sheetView = LiveSportWatchSettingSheetView()
    private let initialSetting: LiveSetting
    private var isDismissingSheet = false
    private var hasPresentedSheet = false
    private var sheetHiddenOffset: CGFloat = 0

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
        sheetView.configure(setting: initialSetting)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheetIfNeeded()
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
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func bindActions() {
        dimmedView.addAction(UIAction { [weak self] _ in
            self?.dismissSheet(animated: true, completion: nil)
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
}
