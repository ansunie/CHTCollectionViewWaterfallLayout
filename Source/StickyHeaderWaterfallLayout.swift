//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {

    /// 滚动超过多少 pt 后 header 吸顶
    public var pinStartOffset: CGFloat = 0

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView,
            let superAttrs = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else { return nil }

        var attrs = superAttrs

        // 把所有 Header 加进 attrs
        for section in 0..<collectionView.numberOfSections {
            let idxPath = IndexPath(item: 0, section: section)
            if !attrs.contains(where: { $0.indexPath.section == section &&
                                        $0.representedElementKind == UICollectionView.elementKindSectionHeader }),
               let headerAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     at: idxPath).copy() as? UICollectionViewLayoutAttributes {
                attrs.append(headerAttr)
            }
        }

        let scrollY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        for header in attrs where header.representedElementKind == UICollectionView.elementKindSectionHeader {
            let section = header.indexPath.section
            guard
                let itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
                itemCount > 0,
                let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                let lastItem  = layoutAttributesForItem(at: IndexPath(item: itemCount - 1, section: section))
            else { continue }

            let headerH      = header.frame.height
            let sectionMinY  = firstItem.frame.minY
            let sectionMaxY  = lastItem.frame.maxY + sectionInset.bottom

            /// Header 在流式布局中的“自然”坐标
            let naturalY     = sectionMinY - headerH

            /// ① 跟随滚动，保持贴紧 Item
            let candidateY   = naturalY - scrollY         // 始终 sectionMinY - headerH - scrollY  → 间距 0

            /// ② 吸顶位置
            let stickY       = -pinStartOffset

            /// 取更靠下（更大的）Y：未达阈值用 candidateY，达阈值后 stickY 生效
            let followOrStick = max(candidateY, stickY)

            /// ③ 不超过本 section 尾部
            let maxY         = sectionMaxY - headerH
            header.frame.origin.y = min(followOrStick, maxY)
            header.zIndex = 999
        }

        return attrs
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
}
