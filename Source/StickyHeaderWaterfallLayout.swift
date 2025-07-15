//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//
import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {

    public var pinStartOffset: CGFloat = 0

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let superAttributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }),
            let collectionView = collectionView
        else { return nil }

        var attrs = superAttributes

        // 把不在可视区域里的 header 也补进来，避免闪烁
        (0..<collectionView.numberOfSections).forEach { section in
            let indexPath = IndexPath(item: 0, section: section)
            if !attrs.contains(where: { $0.indexPath.section == section &&
                                        $0.representedElementKind == UICollectionView.elementKindSectionHeader }),
               let header = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                  at: indexPath)
                                .copy() as? UICollectionViewLayoutAttributes {
                attrs.append(header)
            }
        }

        // 实际滚动位置（扣掉 contentInset.top）
        let currentTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        // 处理所有 header 的吸顶
        for header in attrs where header.representedElementKind == UICollectionView.elementKindSectionHeader {
            let section = header.indexPath.section
            guard let itemCount = collectionView.dataSource?.collectionView(collectionView,
                                                                            numberOfItemsInSection: section),
                  itemCount > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem  = layoutAttributesForItem(at: IndexPath(item: itemCount - 1, section: section))
            else { continue }

            let headerH     = header.frame.height
            let sectionMinY = firstItem.frame.minY
            let sectionMaxY = lastItem.frame.maxY + sectionInset.bottom

            // header 原始 Y、允许的最大 Y、触发吸顶的阈值
            let originalY   = sectionMinY - headerH
            let maxY        = sectionMaxY - headerH
            let triggerY    = originalY - pinStartOffset   // 只有滚过 triggerY 才开始固定

            // 计算 header 的新位置
            var newY = max(currentTop, triggerY)
            newY = min(newY, maxY)

            header.frame.origin.y = newY
            header.zIndex = 999
        }

        return attrs
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
