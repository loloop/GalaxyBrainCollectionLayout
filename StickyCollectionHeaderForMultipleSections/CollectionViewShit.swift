//
//  CollectionViewShit.swift
//  StickyCollectionHeaderForMultipleSections
//
//  Created by Mauricio Cardozo on 5/19/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import Foundation
import UIKit

public protocol Section: AnyObject {
    func numberOfItemsInSection() -> Int
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func register(_ collectionView: UICollectionView)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForSuperHeaderInSection section: Int) -> CGSize?
}

public extension Section {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView { UICollectionReusableView() }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize? {  nil }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForSuperHeaderInSection section: Int) -> CGSize? { nil }
}

public protocol HasCollectionView: AnyObject {
    var collectionView: CollectionView { get }
}

public final class CollectionView: UICollectionView {

    private let _dataSource: DataSource

    public init(sections: [Section], layout: UICollectionViewLayout) {
        _dataSource = DataSource(sections: sections)
        super.init(frame: .zero, collectionViewLayout: layout)
        self.dataSource = _dataSource
        self.delegate = _dataSource
        sections.forEach { $0.register(self) }
        (layout as? GalaxyBrainCollectionLayout)?.delegate = _dataSource
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reload(section: Section) {
        guard let index = _dataSource.sections.firstIndex(where: { innerSection in
            innerSection === section
        }) else { return }

        reloadSections(IndexSet([index]))
    }
}

public final class DataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GalaxyBrainLayoutDelegate {

    public var sections: [Section]

    public init(sections: [Section]) {
        self.sections = sections
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].numberOfItemsInSection()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        sections[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sections[indexPath.section].collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].collectionView(collectionView, didSelectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        sections[indexPath.section].collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let size = sections[section].collectionView(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) else {
            return .zero
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForSuperHeaderInSection section: Int) -> CGSize {
        guard let size = sections[section].collectionView(collectionView, layout: collectionViewLayout, referenceSizeForSuperHeaderInSection: section) else {
            return .zero
        }
        return size
    }
}

extension UICollectionView {
    public func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
    }

    public func register<T: UICollectionReusableView>(_: T.Type, supplementaryViewOfKind: String) {
        register(T.self, forSupplementaryViewOfKind: supplementaryViewOfKind, withReuseIdentifier: String(describing: T.self))
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier : \(String(describing: T.self))")
        }

        return cell
    }

    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue view with identifier : \(String(describing: T.self))")
        }

        return view
    }
}

extension UIView {
    public func constrainToEdges(of view: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
        ])
    }
}

public extension UIDevice {

    @objc var hardwareModel: String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)

        return String(cString: machine)
    }

    @objc var isTablet: Bool {
        return hardwareModel.lowercased().contains("ipad")
    }

    private static let allOLEDModels = [
        "iPhone10,3",
        "iPhone10,6",
        "iPhone11,2",
        "iPhone11,4",
        "iPhone11,6",
        "iPhone12,3",
        "iPhone12,5"
    ]

    private static let allModelWithEars = [
        "iPhone10,3",
        "iPhone10,6",
        "iPhone11,2",
        "iPhone11,4",
        "iPhone11,6",
        "iPhone11,8",
        "iPhone12,1",
        "iPhone12,3",
        "iPhone12,5"
    ]

    var screenCornerRadius: CGFloat {
        let keyPrefix = "_"
        return UIScreen.main.value(forKey: keyPrefix+"displayCornerRadius") as? CGFloat ?? 0
    }

    var hasRoundedCorners: Bool {
        return hasEars || !screenCornerRadius.isZero
    }

    var hasEars: Bool {
        return UIDevice.allModelWithEars.contains(hardwareModel)
    }

    @objc var isOLEDModel: Bool {
        return UIDevice.allOLEDModels.contains(hardwareModel)
    }

}
