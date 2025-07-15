//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {
    
    /// Header 被遮挡多少 pt 后开始吸顶，例如 400 表示 header 被遮 400 pt 后吸顶
    public var pinStartOffset: CGFloat = 0

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView,
            let superAttributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else {
            return nil
        }

        var attributes = superAttributes

        // 确保所有 header 都参与 layout（避免因为不在 rect 而漏算）
        for section in 0..<collectionView.numberOfSections {
            let indexPath = IndexPath(item: 0, section: section)
            let hasHeader = attributes.contains {
                $0.indexPath.section == section && $0.representedElementKind == UICollectionView.elementKindSectionHeader
            }
            if !hasHeader,
               let headerAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                      at: indexPath).copy() as? UICollectionViewLayoutAttributes {
                attributes.append(headerAttr)
            }
        }

        let currentTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        for header in attributes where header.representedElementKind == UICollectionView.elementKindSectionHeader {
            let section = header.indexPath.section
        
            guard let itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
                  itemCount > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem  = layoutAttributesForItem(at: IndexPath(item: itemCount - 1, section: section)) else {
                continue
            }
        
            let sectionMinY = firstItem.frame.minY
            let sectionMaxY = lastItem.frame.maxY + sectionInset.bottom
            let headerHeight = header.frame.height
        
            /// ✅ header 最初的 layout Y：在 section 内容之上
            let originalY = sectionMinY - headerHeight
        
            /// ✅ 滚动到 header 被遮挡 pinStartOffset 时才吸顶
            let triggerY = originalY + pinStartOffset
        
            let currentTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
            let minY = max(currentTop, triggerY)
            let maxY = sectionMaxY - headerHeight
        
            header.frame.origin.y = min(minY, maxY)
            header.zIndex = 999
        }

        return attributes
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
