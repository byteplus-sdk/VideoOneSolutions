// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Vertical chat list with VIP level badges and system messages.
public final class LiveChatView: UIView {

    private let tableView = UITableView()
    private var messages: [LiveChatMessage] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.25)
        layer.cornerRadius = 12
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
        }
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.register(LiveChatCell.self, forCellReuseIdentifier: LiveChatCell.reuseId)
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableView.automaticDimension
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func append(message: LiveChatMessage) {
        messages.append(message)
        tableView.reloadData()
        if messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }

    public func reload(messages: [LiveChatMessage]) {
        self.messages = messages
        tableView.reloadData()
    }
}

extension LiveChatView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LiveChatCell.reuseId) as? LiveChatCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

private final class LiveChatCell: UITableViewCell {
    static let reuseId = "LiveChatCell"

    private let badgeLabel = UILabel()
    private let contentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(badgeLabel)
        contentView.addSubview(contentLabel)
        badgeLabel.font = UIFont.boldSystemFont(ofSize: 11)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 4
        badgeLabel.layer.masksToBounds = true
        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.systemFont(ofSize: 13)

        badgeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(28)
        }
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeLabel.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: LiveChatMessage) {
        if message.isSystemMessage {
            badgeLabel.isHidden = true
            contentLabel.attributedText = NSAttributedString(
                string: message.content,
                attributes: [.foregroundColor: UIColor.systemYellow,
                             .font: UIFont.italicSystemFont(ofSize: 13)]
            )
            return
        }
        badgeLabel.isHidden = message.userLevel <= 0
        badgeLabel.text = message.userLevel > 0 ? "V\(message.userLevel)" : nil
        badgeLabel.backgroundColor = LiveChatCell.color(forLevel: message.userLevel)
        let attr = NSMutableAttributedString()
        let nameAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemTeal,
            .font: UIFont.boldSystemFont(ofSize: 13)
        ]
        attr.append(NSAttributedString(string: message.userName + ": ", attributes: nameAttr))
        attr.append(NSAttributedString(string: message.content,
                                       attributes: [.foregroundColor: UIColor.white,
                                                    .font: UIFont.systemFont(ofSize: 13)]))
        contentLabel.attributedText = attr
    }

    private static func color(forLevel level: Int) -> UIColor {
        switch level {
        case 1...3: return UIColor.systemGreen
        case 4...6: return UIColor.systemBlue
        case 7...9: return UIColor.systemPurple
        case let l where l >= 10: return UIColor.systemRed
        default: return UIColor.darkGray
        }
    }
}
