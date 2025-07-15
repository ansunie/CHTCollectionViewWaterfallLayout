//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {
    
    /// Header 开始吸顶的偏移（相对于 contentOffsetY + adjustedContentInset.top）
    public var pinStartOffset: CGFloat = 0
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView,
            let superAttributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else {
            return nil
        }
        
        var attributes = superAttributes
        
        // 确保所有 header 都加入 attributes（避免某些 header 因不在 rect 内未参与吸顶计算）
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
        
        // 遍历 header，处理吸顶逻辑
        for header in attributes where header.representedElementKind == UICollectionView.elementKindSectionHeader {
            let section = header.indexPath.section
            
            guard let numberOfItems = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
                  numberOfItems > 0,
                  let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem  = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                continue
            }
            
            let headerHeight = header.frame.height
            let sectionMinY  = firstItem.frame.minY
            let sectionMaxY  = lastItem.frame.maxY + sectionInset.bottom
            
            let originalY = sectionMinY - headerHeight
            let triggerY  = originalY - pinStartOffset
            
            let maxY = sectionMaxY - headerHeight
            let minY = max(currentTop, triggerY)
            
            header.frame.origin.y = min(minY, maxY)
            header.zIndex = 999
        }
        
        return attributes
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
