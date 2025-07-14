//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//
import UIKit
import CHTCollectionViewWaterfallLayout

open class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let collectionView = self.collectionView else {
            return nil
        }
        
        var newAttributes = [UICollectionViewLayoutAttributes]()
        var headers = [Int: UICollectionViewLayoutAttributes]()
        var items = [UICollectionViewLayoutAttributes]()
        
        // 分类处理 item 和 header
        for attr in superAttributes {
            if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                headers[attr.indexPath.section] = attr.copy() as? UICollectionViewLayoutAttributes
            } else {
                items.append(attr.copy() as! UICollectionViewLayoutAttributes)
            }
        }

        newAttributes.append(contentsOf: items)

        // 遍历每个 section 的 header，处理其悬浮逻辑
        for (section, headerAttr) in headers {
            guard let firstItemAttr = layoutAttributesForItem(at: IndexPath(item: 0, section: section)) else { continue }

            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let lastItemIndex = max(0, numberOfItems - 1)
            let lastItemAttr = layoutAttributesForItem(at: IndexPath(item: lastItemIndex, section: section))
            
            let contentOffsetY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
            var frame = headerAttr.frame
            let minY = firstItemAttr.frame.minY - frame.height
            let maxY = (lastItemAttr?.frame.maxY ?? firstItemAttr.frame.maxY) - frame.height

            // 悬停逻辑
            let adjustedY = max(minY, min(contentOffsetY, maxY))
            frame.origin.y = adjustedY

            headerAttr.frame = frame
            headerAttr.zIndex = 1024

            newAttributes.append(headerAttr)
        }

        return newAttributes
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
