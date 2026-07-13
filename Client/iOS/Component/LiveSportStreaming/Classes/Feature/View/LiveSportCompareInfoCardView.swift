// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Description card shared by all three compare pages: body text + optional
/// emphasized line + optional bullet list + a "View Docs" button.
public final class LiveSportCompareInfoCardView: UIView {

    public var onDoc: (() -> Void)?

    private let contentStack = UIStackView()
    private let bodyLabel = UILabel()
    private let emphasisLabel = UILabel()
    private let bulletStack = UIStackView()
    private let docButton = UIButton(type: .system)

    private let textColor = UIColor(red: 115.0 / 255.0, green: 122.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(body: String, emphasis: String? = nil, bullets: [String] = [], docTitle: String) {
        bodyLabel.text = body

        if let emphasis = emphasis, !emphasis.isEmpty {
            emphasisLabel.text = emphasis
            emphasisLabel.isHidden = false
        } else {
            emphasisLabel.isHidden = true
        }

        bulletStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if bullets.isEmpty {
            bulletStack.isHidden = true
        } else {
            bulletStack.isHidden = false
            for bullet in bullets {
                let label = UILabel()
                label.text = "• " + bullet
                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = textColor
                label.numberOfLines = 0
                bulletStack.addArrangedSubview(label)
            }
        }

        docButton.setTitle(docTitle, for: .normal)
    }

    private func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        bodyLabel.font = UIFont.systemFont(ofSize: 12)
        bodyLabel.textColor = textColor
        bodyLabel.numberOfLines = 0

        emphasisLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        emphasisLabel.textColor = textColor
        emphasisLabel.numberOfLines = 0

        bulletStack.axis = .vertical
        bulletStack.spacing = 8
        bulletStack.alignment = .fill

        docButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        docButton.setTitleColor(UIColor(red: 48.0 / 255.0, green: 111.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0), for: .normal)
        docButton.backgroundColor = UIColor(red: 245.0 / 255.0, green: 249.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        docButton.layer.cornerRadius = 20
        docButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        docButton.addAction(UIAction { [weak self] _ in
            self?.onDoc?()
        }, for: .touchUpInside)
        docButton.snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        contentStack.addArrangedSubview(bodyLabel)
        contentStack.addArrangedSubview(emphasisLabel)
        contentStack.addArrangedSubview(bulletStack)
        contentStack.addArrangedSubview(docButton)
    }
}
