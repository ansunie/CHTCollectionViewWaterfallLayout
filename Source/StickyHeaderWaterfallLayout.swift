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
        
            // header 在“自然”位置（紧贴第一个 item 之上）
            let naturalY     = sectionMinY - headerH
        
            // ① 跟随 item —— 这里直接用 naturalY
            let candidateY   = naturalY
        
            // ② 吸顶位置
            let stickY       = -pinStartOffset          // collectionView 内部坐标
        
            // 未达阈值用 candidateY，超过阈值后 stickY 生效
            let followOrStick = max(candidateY, stickY)
        
            // ③ 不可超过本 section 尾部
            let maxY         = sectionMaxY - headerH
            header.frame.origin.y = min(followOrStick, maxY)
        
            header.zIndex = 1024        // 确保盖在 cell 之上
        }

        return attrs
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
}
