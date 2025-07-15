//
//  StickyHeaderWaterfallLayout.swift
//  FindsQC
//
//  Created by ansunie on 2025/7/14.
//
import UIKit
import CHTCollectionViewWaterfallLayout

public final class StickyHeaderWaterfallLayout: CHTCollectionViewWaterfallLayout {

   public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let collectionView = collectionView else {
            return nil
        }

          var newAttributes = superAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
      
          // 获取所有 section header
          let numberOfSections = collectionView.numberOfSections
          for section in 0..<numberOfSections {
              let indexPath = IndexPath(item: 0, section: section)
              // 如果当前 header 不在列表中，手动补上
              if !superAttributes.contains(where: { $0.indexPath.section == section && $0.representedElementKind == UICollectionView.elementKindSectionHeader }) {
                  if let headerAttr = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath).copy() as? UICollectionViewLayoutAttributes {
                      newAttributes.append(headerAttr)
                  }
              }
          }

        let contentOffsetY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        // 拷贝 attributes，避免冲突
        for attr in superAttributes {
            guard let copied = attr.copy() as? UICollectionViewLayoutAttributes else { continue }
            newAttributes.append(copied)
        }

        // 按 section 处理 header 吸顶逻辑
        let headers = newAttributes.filter {
            $0.representedElementKind == UICollectionView.elementKindSectionHeader
        }

        for header in headers {
            let section = header.indexPath.section

            guard let numberOfItems = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
                  numberOfItems > 0,
                  let firstItemAttr = layoutAttributesForItem(at: IndexPath(item: 0, section: section))?.copy() as? UICollectionViewLayoutAttributes,
                  let lastItemAttr = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section))?.copy() as? UICollectionViewLayoutAttributes
            else {
                continue
            }

            // 当前 section 范围
            let sectionMinY = firstItemAttr.frame.minY
            let sectionMaxY = lastItemAttr.frame.maxY + self.sectionInset.bottom

            let headerHeight = header.frame.height
            var newHeaderY = contentOffsetY

            // 限制吸顶范围不能超过当前 section
            let maxHeaderY = sectionMaxY - headerHeight
            let minHeaderY = sectionMinY - headerHeight
            newHeaderY = max(newHeaderY, minHeaderY)
            newHeaderY = min(newHeaderY, maxHeaderY)
            print("newheady  =  \(newHeaderY) \(maxHeaderY) \(minHeaderY)")
            header.frame.origin.y = newHeaderY
            header.zIndex = 999
        }

        return newAttributes
    }

   public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
