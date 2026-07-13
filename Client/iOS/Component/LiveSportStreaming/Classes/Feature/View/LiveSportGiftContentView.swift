// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// A single gift cell in the gift catalog grid: icon + name, with a gradient
/// "Send" button that replaces the name once the cell is selected.
final class LiveSportGiftCell: UICollectionViewCell {

    static let reuseIdentifier = "LiveSportGiftCell"

    var onSend: (() -> Void)?

    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let sendButton = UIButton(type: .system)
    private let sendGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with gift: LiveSportGift, selected: Bool) {
        iconView.image = gift.icon
        nameLabel.text = gift.displayName
        applySelection(selected)
    }

    private func applySelection(_ selected: Bool) {
        nameLabel.isHidden = selected
        sendButton.isHidden = !selected
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSend = nil
        applySelection(false)
    }

    private func setupSubviews() {
        contentView.addSubview(iconView)
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }

        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        sendGradientLayer.colors = [
            UIColor(red: 1.0, green: 23.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).cgColor,
            UIColor(red: 237.0 / 255.0, green: 53.0 / 255.0, blue: 150.0 / 255.0, alpha: 1.0).cgColor
        ]
        sendGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        sendGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        sendGradientLayer.cornerRadius = 12
        sendGradientLayer.frame = CGRectMake(0, 0, 56, 24)

        contentView.addSubview(sendButton)
        sendButton.isHidden = true
        sendButton.setTitle(LiveSportL10n("live_sport_gift_send_action"), for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        sendButton.layer.cornerRadius = 12
        sendButton.layer.masksToBounds = true
        sendButton.layer.insertSublayer(sendGradientLayer, at: 0)
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(24)
        }
        sendButton.addAction(UIAction { [weak self] _ in
            self?.onSend?()
        }, for: .touchUpInside)
    }
}

/// Vertically scrolling gift catalog grid backed by a `UICollectionView`. Items
/// are laid out at most 4 per row with the available width split evenly across
/// the 4 columns; rows wrap and the grid scrolls vertically when it overflows.
/// Tapping a cell selects it (revealing its Send button); tapping Send fires
/// `onSend`.
final class LiveSportGiftContentView: UIView {

    var onSend: ((LiveSportGift) -> Void)?

    private let titleLabel = UILabel()
    private let flowLayout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    private let gifts: [LiveSportGift]
    private var selectedIndex: Int?

    private let columnCount = 4
    private let rowSpacing: CGFloat = 16
    private let columnSpacing: CGFloat = 12
    private let horizontalInset: CGFloat = 16
    private let cellHeight: CGFloat = 78
    private let bottomPadding: CGFloat = 16

    init(gifts: [LiveSportGift] = LiveSportGiftCatalog.all) {
        self.gifts = gifts
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        super.init(frame: .zero)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        backgroundColor = UIColor(red: 6.0 / 255.0, green: 18.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)

        addSubview(titleLabel)
        titleLabel.text = LiveSportL10n("live_sport_send_gift")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(horizontalInset)
            make.trailing.equalToSuperview().offset(-horizontalInset)
        }

        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = columnSpacing
        flowLayout.minimumLineSpacing = rowSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: bottomPadding, right: horizontalInset)

        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LiveSportGiftCell.self, forCellWithReuseIdentifier: LiveSportGiftCell.reuseIdentifier)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateItemSize()
    }

    private func updateItemSize() {
        let available = collectionView.bounds.width - 2 * horizontalInset - CGFloat(columnCount - 1) * columnSpacing
        guard available > 0 else { return }
        let width = floor(available / CGFloat(columnCount))
        let newSize = CGSize(width: width, height: cellHeight)
        if flowLayout.itemSize != newSize {
            flowLayout.itemSize = newSize
            flowLayout.invalidateLayout()
        }
    }
}

extension LiveSportGiftContentView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gifts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveSportGiftCell.reuseIdentifier, for: indexPath)
        guard let giftCell = cell as? LiveSportGiftCell, gifts.indices.contains(indexPath.item) else {
            return cell
        }
        let gift = gifts[indexPath.item]
        giftCell.configure(with: gift, selected: selectedIndex == indexPath.item)
        giftCell.onSend = { [weak self] in
            self?.onSend?(gift)
        }
        return giftCell
    }
}

extension LiveSportGiftContentView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard gifts.indices.contains(indexPath.item) else { return }
        guard indexPath.item != selectedIndex else { return }
        let previous = selectedIndex
        selectedIndex = indexPath.item
        var toReload = [indexPath]
        if let previous = previous, previous != indexPath.item {
            toReload.append(IndexPath(item: previous, section: 0))
        }
        collectionView.reloadItems(at: toReload)
    }
}
