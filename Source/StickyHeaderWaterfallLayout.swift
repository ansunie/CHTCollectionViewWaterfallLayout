//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {
    
    /// Header 被滚动多少点后开始吸顶
    public var pinStartOffset: CGFloat = 0

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView,
            let superAttrs = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else {
            return nil
        }

        var attributes = superAttrs

        // 确保 header 都加入
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
                  let lastItem = layoutAttributesForItem(at: IndexPath(item: itemCount - 1, section: section))
            else { continue }

            let headerHeight = header.frame.height
            let sectionMaxY = lastItem.frame.maxY + sectionInset.bottom
            let maxY = sectionMaxY - headerHeight

            let pinnedY: CGFloat
            if scrollY < pinStartOffset {
                pinnedY = -scrollY
            } else {
                pinnedY = -pinStartOffset
            }

            header.frame.origin.y = min(pinnedY, maxY)
            header.zIndex = 999
        }

        return attributes
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
