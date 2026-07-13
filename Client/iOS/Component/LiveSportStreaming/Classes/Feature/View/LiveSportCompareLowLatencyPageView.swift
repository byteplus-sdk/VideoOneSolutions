// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Low-latency compare page: info card + two video cards, each card has its own
/// protocol pill selector and a video tile.
public final class LiveSportCompareLowLatencyPageView: UIView {

    /// Called when a protocol pill is tapped. `isTop` distinguishes the two cards.
    public var onProtocolSelect: ((_ isTop: Bool, _ streamProtocol: StreamProtocol) -> Void)?

    public let infoCard = LiveSportCompareInfoCardView()
    public let topTile = LiveSportCompareVideoTile()
    public let bottomTile = LiveSportCompareVideoTile()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let topPill = LiveSportComparePillSegment()
    private let bottomPill = LiveSportComparePillSegment()

    private let protocols = StreamProtocol.allCases

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }

        infoCard.configure(body: LiveSportL10n("live_sport_compare_low_latency_desc"),
                           emphasis: LiveSportL10n("live_sport_compare_latency_brief"),
                           docTitle: LiveSportL10n("live_sport_compare_view_doc"))
        contentStack.addArrangedSubview(infoCard)

        let titles = protocols.map { $0.displayName }
        topPill.configure(titles: titles, selected: 0)
        bottomPill.configure(titles: titles, selected: 0)
        topPill.onSelect = { [weak self] index in
            guard let self = self else { return }
            self.onProtocolSelect?(true, self.protocols[index])
        }
        bottomPill.onSelect = { [weak self] index in
            guard let self = self else { return }
            self.onProtocolSelect?(false, self.protocols[index])
        }

        contentStack.addArrangedSubview(makeVideoCard(pill: topPill, tile: topTile))
        contentStack.addArrangedSubview(makeVideoCard(pill: bottomPill, tile: bottomTile))
    }

    private func makeVideoCard(pill: LiveSportComparePillSegment, tile: LiveSportCompareVideoTile) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6

        card.addSubview(pill)
        pill.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        card.addSubview(tile)
        tile.snp.makeConstraints { make in
            make.top.equalTo(pill.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(tile.snp.width).multipliedBy(9.0 / 16.0)
        }
        return card
    }
}
