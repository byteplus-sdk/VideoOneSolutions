// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public protocol LiveStreamChannelViewDelegate: AnyObject {
    func channelView(_ view: LiveStreamChannelView, didSelect channel: LiveStreamChannel)
}

/// Horizontal selectable channel list shown at the bottom of the watch page.
public final class LiveStreamChannelView: UIView {

    public weak var delegate: LiveStreamChannelViewDelegate?

    private let stackView = UIStackView()
    private var channels: [LiveStreamChannel] = []
    private var selectedId: String?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(channels: [LiveStreamChannel], selectedId: String?) {
        self.channels = channels
        self.selectedId = selectedId
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for channel in channels {
            let cell = makeCell(for: channel, selected: channel.id == selectedId)
            stackView.addArrangedSubview(cell)
        }
    }

    private func makeCell(for channel: LiveStreamChannel, selected: Bool) -> UIView {
        let container = UIControl()
        container.layer.cornerRadius = 8
        container.layer.borderWidth = selected ? 2 : 1
        container.layer.borderColor = (selected ? UIColor.systemBlue : UIColor.lightGray).cgColor
        container.backgroundColor = selected ? UIColor.systemBlue.withAlphaComponent(0.08) : UIColor.white

        let label = UILabel()
        label.text = channel.title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: selected ? .semibold : .regular)
        label.textColor = selected ? UIColor.systemBlue : UIColor.black
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        let id = channel.id
        container.addAction(UIAction { [weak self] _ in
            guard let self = self,
                  let target = self.channels.first(where: { $0.id == id }) else {
                return
            }
            self.selectedId = id
            self.configure(channels: self.channels, selectedId: id)
            self.delegate?.channelView(self, didSelect: target)
        }, for: .touchUpInside)
        return container
    }
}
