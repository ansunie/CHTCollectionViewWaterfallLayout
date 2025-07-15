//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {

    /// Header 吸顶触发偏移点（例如 400 表示滚动超过 400 pt 开始吸顶）
    public var pinStartOffset: CGFloat = 0

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView,
            let superAttrs = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else {
            return nil
        }

        var attributes = superAttrs

        // 确保所有 header 都参与 layout
        for section in 0..<collectionView.numberOfSections {
            let indexPath = IndexPath(item: 0, section: section)
            if !attributes.contains(where: {
                $0.indexPath.section == section && $0.representedElementKind == UICollectionView.elementKindSectionHeader
            }),
               let headerAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                      at: indexPath).copy() as? UICollectionViewLayoutAttributes {
                attributes.append(headerAttr)
            }
        }

        let scrollY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        for header in attributes where header.representedElementKind == UICollectionView.elementKindSectionHeader {
            let section = header.indexPath.section

            guard let itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
                  itemCount > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem = layoutAttributesForItem(at: IndexPath(item: itemCount - 1, section: section))
            else {
                continue
            }

            let sectionMaxY = lastItem.frame.maxY + sectionInset.bottom
            let headerHeight = header.frame.height

            // header 固定时的吸附位置
            let stickY = -pinStartOffset

            // 如果回弹状态，header 最低能下移到这里（item 顶部碰到 header 底部）
            let maxHeaderY = firstItem.frame.minY - headerHeight

            let newY: CGFloat
            if scrollY >= pinStartOffset {
                // 向上滚 → 吸顶（也限制不超出 section 尾部）
                newY = min(max(stickY, maxHeaderY), sectionMaxY - headerHeight)
            } else {
                // 向下滚 → 跟随滚动
                newY = -scrollY
            }

            header.frame.origin.y = newY
            header.zIndex = 999
        }

        return attributes
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
