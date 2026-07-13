// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportWatchChatView: UIView {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var messages: [LiveChatMessage] = []
    private let baseBottomInset: CGFloat = 4

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reload(messages: [LiveChatMessage]) {
        self.messages = messages
        tableView.reloadData()
        updateVerticalAlignment(animated: false)
    }

    public func append(message: LiveChatMessage) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.performBatchUpdates {
            tableView.insertRows(at: [indexPath], with: .none)
        } completion: { _ in
            self.updateVerticalAlignment(animated: true)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateVerticalAlignment(animated: false)
    }

    private func setupSubviews() {
        backgroundColor = .clear
        addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: baseBottomInset, right: 0)
        tableView.estimatedRowHeight = 28
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseIdentifier)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateVerticalAlignment(animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()
            guard !self.messages.isEmpty else {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.baseBottomInset, right: 0)
                return
            }
            let availableHeight = self.tableView.bounds.height
            let topInset = max(availableHeight - self.tableView.contentSize.height - self.baseBottomInset, 0)
            self.tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: self.baseBottomInset, right: 0)
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
}

extension LiveSportWatchChatView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier,
                                                       for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        cell.configure(message: messages[indexPath.row])
        return cell
    }
}

private final class ChatMessageCell: UITableViewCell {
    static let reuseIdentifier = "ChatMessageCell"

    private let bubbleView = UIView()
    private let messageLabelView = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: LiveChatMessage) {
        bubbleView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        if message.isSystemMessage {
            messageLabelView.textColor = UIColor.white.withAlphaComponent(0.92)
            messageLabelView.attributedText = nil
            messageLabelView.text = message.content
        } else {
            messageLabelView.text = nil
            messageLabelView.attributedText = makeMessageAttributedText(message: message)
        }
    }

    private func setupSubviews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.layer.cornerRadius = 12
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        messageLabelView.numberOfLines = 0
        messageLabelView.lineBreakMode = .byWordWrapping
        messageLabelView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bubbleView.addSubview(messageLabelView)
        messageLabelView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }
    }

    private func makeMessageAttributedText(message: LiveChatMessage) -> NSAttributedString {
        let text = NSMutableAttributedString()
        let messageFont = UIFont.systemFont(ofSize: 13, weight: .medium)
        let nicknameAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 140.0 / 255.0, green: 231.0 / 255.0, blue: 1.0, alpha: 1.0),
            .font: messageFont
        ]
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: messageFont
        ]

        if message.userLevel > 0, let attachment = badgeAttachment(level: message.userLevel) {
            text.append(NSAttributedString(attachment: attachment))
            text.append(NSAttributedString(string: " ", attributes: contentAttributes))
        }

        text.append(NSAttributedString(string: message.userName, attributes: nicknameAttributes))

        if !message.content.isEmpty {
            text.append(NSAttributedString(string: " ", attributes: contentAttributes))
            text.append(NSAttributedString(string: message.content, attributes: contentAttributes))
        }

        return text
    }

    private func badgeAttachment(level: Int) -> NSTextAttachment? {
        let label = PaddingLabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        label.text = "VIP\(level)"
        label.backgroundColor = badgeColor(level: level)
        label.layer.cornerRadius = 7
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor(red: 1.0, green: 214.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0).cgColor
        label.layer.masksToBounds = true
        label.contentInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        let imageSize = label.intrinsicContentSize
        label.bounds = CGRect(origin: .zero, size: imageSize)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { _ in
            label.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -2, width: imageSize.width, height: imageSize.height)
        return attachment
    }

    private func badgeColor(level: Int) -> UIColor {
        switch level {
        case 1:
            return UIColor(red: 31.0 / 255.0, green: 136.0 / 255.0, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 92.0 / 255.0, green: 98.0 / 255.0, blue: 1.0, alpha: 1.0)
        default:
            return UIColor(red: 130.0 / 255.0, green: 43.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
    }
}

private final class PaddingLabel: UILabel {
    var contentInset: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInset.left + contentInset.right,
                      height: size.height + contentInset.top + contentInset.bottom)
    }
}
