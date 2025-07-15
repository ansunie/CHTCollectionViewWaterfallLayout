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
            let superAttrs = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes },
            let collectionView = collectionView
        else { return nil }

        var attrs = superAttrs

        // 把所有 header 都加进来，避免未渲染 section 出现闪烁
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

        let currentTop = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        // 排序后能轻松取到“下一个 header”
        let headers = attrs
            .filter { $0.representedElementKind == UICollectionView.elementKindSectionHeader }
            .sorted { $0.indexPath.section < $1.indexPath.section }

        for (idx, header) in headers.enumerated() {
            let originalY = header.frame.origin.y
            let triggerY  = originalY - pinStartOffset      // 到达 trigger 才开始吸顶

            // 计算可移动范围的上/下限
            let minY = max(currentTop, triggerY)

            let nextHeaderMinY = (idx + 1 < headers.count) ?
                                 headers[idx + 1].frame.minY :
                                 .greatestFiniteMagnitude
            let maxY = nextHeaderMinY - header.frame.height

            header.frame.origin.y = min(minY, maxY)
            header.zIndex = 999
        }

        return attrs
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
}
