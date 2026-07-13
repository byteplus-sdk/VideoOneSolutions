// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// L3 pill selector used by the low-latency protocol picker and the cost-saving
/// mode picker. It scrolls horizontally when the pills overflow, and centers the
/// content when the pills do not fill the available width. Selected pills use a
/// filled blue background, others are plain.
public final class LiveSportComparePillSegment: UIView {

    public var onSelect: ((Int) -> Void)?

    private let layout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView
    private var titles: [String] = []
    private var itemWidths: [CGFloat] = []
    private var selectedIndex: Int = 0

    private let pillHeight: CGFloat = 32
    private let interItemSpacing: CGFloat = 12
    private let pillHorizontalPadding: CGFloat = 32
    private let pillFont = UIFont.systemFont(ofSize: 14, weight: .medium)

    private let selectedBackground = UIColor(red: 226.0 / 255.0, green: 238.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    private let selectedText = UIColor(red: 0.0, green: 102.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    private let normalText = UIColor(red: 115.0 / 255.0, green: 122.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)

    public override init(frame: CGRect) {
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(titles: [String], selected: Int) {
        self.titles = titles
        itemWidths = titles.map { title in
            let textWidth = (title as NSString).size(withAttributes: [.font: pillFont]).width
            return ceil(textWidth) + pillHorizontalPadding
        }
        selectedIndex = min(max(selected, 0), max(titles.count - 1, 0))
        collectionView.reloadData()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    public func setSelected(_ index: Int) {
        guard index >= 0, index < titles.count else { return }
        let previousIndex = selectedIndex
        selectedIndex = index
        guard previousIndex != index else { return }
        refreshPillAppearance(at: previousIndex)
        refreshPillAppearance(at: index)
    }

    private func refreshPillAppearance(at index: Int) {
        guard index >= 0, index < titles.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? LiveSportComparePillCell else { return }
        cell.apply(title: titles[index],
                   selected: index == selectedIndex,
                   selectedBackground: selectedBackground,
                   selectedText: selectedText,
                   normalText: normalText)
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: pillHeight)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        centerContentIfNeeded()
    }

    private func setupSubviews() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LiveSportComparePillCell.self, forCellWithReuseIdentifier: LiveSportComparePillCell.reuseID)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(pillHeight)
        }
    }

    private func centerContentIfNeeded() {
        collectionView.layoutIfNeeded()
        let contentWidth = collectionView.collectionViewLayout.collectionViewContentSize.width
        let available = collectionView.bounds.width
        let leftInset = contentWidth < available ? (available - contentWidth) / 2.0 : 0
        let newInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        if collectionView.contentInset != newInset {
            collectionView.contentInset = newInset
        }
    }
}

extension LiveSportComparePillSegment: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveSportComparePillCell.reuseID, for: indexPath)
        if let pillCell = cell as? LiveSportComparePillCell {
            pillCell.apply(title: titles[indexPath.item],
                           selected: indexPath.item == selectedIndex,
                           selectedBackground: selectedBackground,
                           selectedText: selectedText,
                           normalText: normalText)
        }
        return cell
    }
}

extension LiveSportComparePillSegment: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = indexPath.item < itemWidths.count ? itemWidths[indexPath.item] : pillHorizontalPadding
        return CGSize(width: width, height: pillHeight)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setSelected(indexPath.item)
        onSelect?(indexPath.item)
    }
}

private final class LiveSportComparePillCell: UICollectionViewCell {

    static let reuseID = "LiveSportComparePillCell"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2.0
    }

    func apply(title: String,
               selected: Bool,
               selectedBackground: UIColor,
               selectedText: UIColor,
               normalText: UIColor) {
        label.text = title
        if selected {
            contentView.backgroundColor = selectedBackground
            label.textColor = selectedText
        } else {
            contentView.backgroundColor = .clear
            label.textColor = normalText
        }
    }
}
