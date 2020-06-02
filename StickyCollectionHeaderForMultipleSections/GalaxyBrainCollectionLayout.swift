//
//  GalaxyBrainCollectionLayout.swift
//  StickyCollectionHeaderForMultipleSections
//
//  Created by Mauricio Cardozo on 5/26/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import UIKit

final class GalaxyBrainLayoutAttributes: UICollectionViewLayoutAttributes {
    var origin: CGPoint = .zero

    override func copy(with zone: NSZone?) -> Any {
        guard let copiedAttributes = super.copy(with: zone) as? GalaxyBrainLayoutAttributes else {
            return super.copy(with: zone)
        }

      copiedAttributes.origin = origin
      return copiedAttributes
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let attrs = object as? GalaxyBrainLayoutAttributes else {
            return false
        }

        if attrs.origin != origin {
            return false
        }

        return super.isEqual(object)
    }
}

protocol GalaxyBrainLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForSuperHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

final class GalaxyBrainCollectionLayout: UICollectionViewLayout {

    enum ElementType: String, CaseIterable {
        case sectionHeader = "UICollectionElementKindSectionHeader"
        case sectionFooter = "UICollectionElementKindSectionFooter"
        case superHeader
        case cell
    }

    // MARK: - Public Settings

    var delegate: GalaxyBrainLayoutDelegate?
    var interitemSpacing: CGFloat = .zero
    var interlineSpacing: CGFloat = 5

    // MARK: - Private Vars

    private var collection: UICollectionView {
        assert(collectionView != nil, "GalaxyBrainLayout should have a collectionView")
        return collectionView!
    }

    /// We also could have a currentContentWidth and a `Direction` enum that makes this or width go up. The way this works rn makes this always be a vertical collection
    private var currentContentHeight: CGFloat = .zero
    private var currentZIndex = 0
    private var visibleAttributes: [GalaxyBrainLayoutAttributes] = []
    private var oldBounds: CGRect = .zero

    private var navigationBarHeight: CGFloat { // TODO: figure out the real navigation bar height
        collection.adjustedContentInset.top
    }

    override class var layoutAttributesClass: AnyClass {
        GalaxyBrainLayoutAttributes.self
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: collection.frame.width, height: currentContentHeight)
    }

    // MARK: - ElementCache

    private var elementCache: [ElementType: [IndexPath: GalaxyBrainLayoutAttributes]] = [:]
    private func resetCache() {
        elementCache.removeAll(keepingCapacity: true)
        ElementType.allCases.forEach({elementCache[$0] = [:] })
    }

    // MARK: - Layout Preparation

    override func prepare() {
        guard let delegate = delegate else {
            print("GalaxyBrainCollectionLayout has no delegate!")
            return
        }

        // we also should check for the presence of a delegate here and pass it forward instead of checking it every step
        guard elementCache.isEmpty else { return }
        resetCache()
        oldBounds = collection.bounds
        prepareSections(with: delegate)
    }

    private func prepareSections(with delegate: GalaxyBrainLayoutDelegate) {
        for section in 0 ..< collection.numberOfSections {
            prepareSuperHeader(in: section,
                               attributes: GalaxyBrainLayoutAttributes(forSupplementaryViewOfKind: ElementType.superHeader.rawValue,
                                                                       with: IndexPath(item: 0, section: section)),
                               with: delegate)
            prepareSectionHeader(in: section,
                                 attributes: GalaxyBrainLayoutAttributes(forSupplementaryViewOfKind: ElementType.sectionHeader.rawValue,
                                                                         with: IndexPath(item: 0, section: section)),
                                 with: delegate)
            prepareCells(in: section, with: delegate)
            /// TODO: `prepareSectionFooter`
        }

        guard let headers = elementCache[.sectionHeader] else { return }

        var frozenIndex = currentZIndex
        headers.forEach { (indexPath, attributes) in
            attributes.zIndex = frozenIndex
            frozenIndex += 5
        }

        guard let superHeaders = elementCache[.superHeader] else { return }

        superHeaders.forEach { (indexPath, attributes) in
            attributes.zIndex = frozenIndex
            frozenIndex += 5
        }
    }

    private func prepareCells(in section: Int, with delegate: GalaxyBrainLayoutDelegate) {
        for item in 0 ..< collection.numberOfItems(inSection: section) {
            prepareCell(at: IndexPath(item: item, section: section), with: delegate)
        }
    }

    private func prepareSuperHeader(in section: Int, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        let size = delegate.collectionView(collection, layout: self, referenceSizeForSuperHeaderInSection: section)
        guard size != .zero else { return }

        attributes.origin = CGPoint(x: 0, y: currentContentHeight)
        let lineSpacing = section == 0 ? 0 : interlineSpacing
        let itemSpacing = section == 0 ? 0 : interitemSpacing
        attributes.frame = CGRect(x: attributes.origin.x + itemSpacing, y: attributes.origin.y + lineSpacing, width: size.width, height: size.height)
        attributes.zIndex = currentZIndex
        currentContentHeight = attributes.frame.maxY
        currentZIndex += 1
        elementCache[.superHeader]?[attributes.indexPath] = attributes
    }

    private func prepareSectionHeader(in section: Int, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        let size = delegate.collectionView(collection, layout: self, referenceSizeForHeaderInSection: section)
        guard size != .zero else { return }

        attributes.origin = CGPoint(x: 0, y: currentContentHeight)
        let lineSpacing = section == 0 ? 0 : interlineSpacing
        let itemSpacing = section == 0 ? 0 : interitemSpacing
        attributes.frame = CGRect(x: attributes.origin.x + itemSpacing, y: attributes.origin.y + lineSpacing, width: size.width, height: size.height)
        attributes.zIndex = currentZIndex
        currentContentHeight = attributes.frame.maxY
        currentZIndex += 1
        elementCache[.sectionHeader]?[attributes.indexPath] = attributes
    }

    private func prepareSectionFooter(in section: Int, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        fatalError("TODO: not implemented")
    }

    private func prepareCell(at indexPath: IndexPath, with delegate: GalaxyBrainLayoutDelegate) {
        let size = delegate.collectionView(collection, layout: self, sizeForItemAt: indexPath)
        guard size != .zero else { return }

        let attributes = GalaxyBrainLayoutAttributes(forCellWith: indexPath)
        attributes.origin = CGPoint(x: 0, y: currentContentHeight)
        attributes.frame = CGRect(x: 0 + interitemSpacing, y: currentContentHeight + interlineSpacing, width: size.width, height: size.height)
        attributes.zIndex = currentZIndex
        currentZIndex += 1
        currentContentHeight = attributes.frame.maxY
        elementCache[.cell]?[attributes.indexPath] = attributes
    }

    private func prepareFooter(at indexPath: IndexPath, with delegate: GalaxyBrainLayoutDelegate) {
        fatalError("not implemented")
    }

    // MARK: - LayoutAttributes for CollectionView

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            elementCache.removeAll(keepingCapacity: true)
        }
        return true
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var cache: [IndexPath : UICollectionViewLayoutAttributes]?

        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            cache = elementCache[.sectionHeader]
        case UICollectionView.elementKindSectionFooter:
            cache = elementCache[.sectionFooter]
        case ElementType.superHeader.rawValue:
            cache = elementCache[.superHeader]
        default:
            cache = nil
        }

        return cache?[indexPath]
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        elementCache[.cell]?[indexPath]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let delegate = delegate else {
            print("GalaxyLayout delegate not set")
            return nil
        }
        visibleAttributes.removeAll(keepingCapacity: true)

        for (type, info) in elementCache {
            info.forEach { indexPath, attributes in
                attributes.transform = .identity

                switch type {
                case .sectionHeader:
                    layoutAttributesForSectionHeader(in: indexPath, attributes: attributes, with: delegate)
                case .sectionFooter:
                    break
                case .superHeader:
                    layoutAttributesForSuperHeader(in: indexPath, attributes: attributes, with: delegate)
                case .cell:
                    break
                }

                if attributes.frame.intersects(rect) {
                    visibleAttributes.append(attributes)
                }
            }
        }

        return visibleAttributes
    }

    private func layoutAttributesForSuperHeader(in indexPath: IndexPath, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        /// Since we don't want to overlap superHeaders, this returns only the size for items above a superHeader
        func sizeOfItems(in section: Int) -> CGFloat{
            var itemsSizeSum: CGFloat = .zero
            for item in 0 ..< collection.numberOfItems(inSection: section) {
                itemsSizeSum += delegate.collectionView(collection, layout: self, sizeForItemAt: IndexPath(item: item, section: section)).height + interlineSpacing
            }
            let lineSpacing: CGFloat = indexPath.section == 0 ? 0 : interlineSpacing
            let headerHeight = delegate.collectionView(collection, layout: self, referenceSizeForHeaderInSection: section).height  + lineSpacing
            return itemsSizeSum + headerHeight  // this should eventually take note of the footer size
        }

        var aboveSuperSectionHeights: CGFloat = .zero
        for section in 0 ..< indexPath.section {
            var superHeaderHeight = delegate.collectionView(collection, layout: self, referenceSizeForSuperHeaderInSection: section).height
            if superHeaderHeight > 0 { superHeaderHeight -= interlineSpacing }
            aboveSuperSectionHeights += superHeaderHeight
        }

        let contentOffset = collection.contentOffset.y
        var upperLimitForHeader: CGFloat = .zero
        let offsetNormalizedByBarHeight = contentOffset + navigationBarHeight

        let positionRelativeToTop = attributes.origin.y - offsetNormalizedByBarHeight - aboveSuperSectionHeights

        if indexPath.section > 0 {
            for section in 1 ... indexPath.section {
                upperLimitForHeader += sizeOfItems(in: section - 1)
            }

            if positionRelativeToTop <= 0 {
                attributes.transform = CGAffineTransform(translationX: 0, y: offsetNormalizedByBarHeight - upperLimitForHeader)
            } else if offsetNormalizedByBarHeight < upperLimitForHeader {
                attributes.transform = CGAffineTransform(translationX: 0, y: upperLimitForHeader - max(upperLimitForHeader, offsetNormalizedByBarHeight))
            }
        } else {
            attributes.transform = CGAffineTransform(translationX: 0, y: max(upperLimitForHeader, offsetNormalizedByBarHeight))
        }
    }

    private func layoutAttributesForSectionHeader(in indexPath: IndexPath, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        func sizeOf(section: Int) -> CGFloat{
            let lineSpacing: CGFloat = indexPath.section == 0 ? 0 : interlineSpacing
            let headerHeight = delegate.collectionView(collection, layout: self, referenceSizeForHeaderInSection: section).height + lineSpacing
            var itemsSizeSum: CGFloat = .zero
            for item in 0 ..< collection.numberOfItems(inSection: section) {
                itemsSizeSum += delegate.collectionView(collection, layout: self, sizeForItemAt: IndexPath(item: item, section: section)).height + interlineSpacing
            }

            return itemsSizeSum + headerHeight
        }

        var aboveSectionSize: CGFloat = .zero
        if indexPath.section > 0 {
            for section in 1 ... indexPath.section {
                aboveSectionSize += sizeOf(section: section - 1)
            }
        }

        var lowerLimitForHeader: CGFloat = .zero
        for item in 0 ..< collection.numberOfItems(inSection: indexPath.section) {
            lowerLimitForHeader += delegate.collectionView(collection, layout: self, sizeForItemAt: IndexPath(item: item, section: indexPath.section)).height + interlineSpacing
        }

        let offsetNormalizedByBarHeight = collection.contentOffset.y + navigationBarHeight

        var aboveSuperSectionHeights: CGFloat = .zero
        for section in 0 ..< indexPath.section {
            aboveSuperSectionHeights += delegate.collectionView(collection, layout: self, referenceSizeForSuperHeaderInSection: section).height - interlineSpacing
        }

        let positionRelativeToTop = attributes.origin.y - offsetNormalizedByBarHeight - aboveSuperSectionHeights

        if positionRelativeToTop < -lowerLimitForHeader { // the header should go up
            attributes.transform = CGAffineTransform(translationX: 0, y: lowerLimitForHeader)
        } else if positionRelativeToTop <= 0 { // the header is at the top, so we cancel its
             attributes.transform = CGAffineTransform(translationX: 0, y: offsetNormalizedByBarHeight - aboveSectionSize)
        }
    }

    private func layoutAttributesForSectionFooter(in indexPath: IndexPath, attributes: GalaxyBrainLayoutAttributes, with delegate: GalaxyBrainLayoutDelegate) {
        fatalError("not implemented")
    }

}
