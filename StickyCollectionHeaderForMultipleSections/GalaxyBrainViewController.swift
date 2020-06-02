//
//  GalaxyBrainViewController.swift
//  StickyCollectionHeaderForMultipleSections
//
//  Created by Mauricio Cardozo on 5/19/20.
//  Copyright © 2020 Mauricio Cardozo. All rights reserved.
//

import Foundation
import UIKit

final class GalaxyBrainViewController: UIViewController {

    lazy var collection: CollectionView = {
        let layout = GalaxyBrainCollectionLayout()
        let c = CollectionView(sections: sections, layout: layout)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.backgroundColor = .white
        return c
    }()

    lazy var sections: [Section] = [
        SuperHeaderSection(),
        GalaxySection(),
        ItemlessSection(),
        GalaxySection(),
        HeaderlessSection(),
        GalaxySection(),
        SuperHeaderSection(),
        HeaderlessSection(),
        GalaxySection(headerColor: .red),
        HeaderlessSection(),
        HeaderlessSection(),
        GalaxySection(),
        HeaderlessSection(),
        HeaderlessSection(),
        GalaxySection(),
    ]

    override func loadView() {
        view = UIView()
        view.addSubview(collection)
        collection.constrainToEdges(of: view)
        collection.reloadData()
    }
}

final class ItemlessSection: Section {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize { .zero }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }

    func numberOfItemsInSection() -> Int { 0 }

    func register(_ collectionView: UICollectionView) {
        collectionView.register(GalaxyBrainHeader.self, supplementaryViewOfKind: GalaxyBrainCollectionLayout.ElementType.sectionHeader.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize? {
        CGSize(width: UIScreen.main.bounds.width, height: 151)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == GalaxyBrainCollectionLayout.ElementType.sectionHeader.rawValue {
            let header: GalaxyBrainHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.backgroundColor = .magenta
            header.text = "ItemlessSection\n\(kind) - \(indexPath)"
            return header
        }

        return UICollectionReusableView()
    }

}

final class GalaxySection: Section {

    var headerSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
    var headerColor: UIColor

    init(headerColor: UIColor = .orange) {
        self.headerColor = headerColor
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalaxyBrainCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = .cyan
        return cell
    }

    func numberOfItemsInSection() -> Int {
        5
    }

    func register(_ collectionView: UICollectionView) {
        collectionView.register(GalaxyBrainCell.self)
        collectionView.register(GalaxyBrainHeader.self, supplementaryViewOfKind: GalaxyBrainCollectionLayout.ElementType.sectionHeader.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == GalaxyBrainCollectionLayout.ElementType.sectionHeader.rawValue {
            let header: GalaxyBrainHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.backgroundColor = headerColor
            header.text = "GalaxySection\n\(kind) - \(indexPath)"
            return header
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize? {
        headerSize
    }

}

final class SuperHeaderSection: Section {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalaxyBrainCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = .magenta
        return cell
    }

    func numberOfItemsInSection() -> Int {
        5
    }

    func register(_ collectionView: UICollectionView) {
        collectionView.register(GalaxyBrainCell.self)
        collectionView.register(GalaxyBrainHeader.self, supplementaryViewOfKind: GalaxyBrainCollectionLayout.ElementType.superHeader.rawValue)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == GalaxyBrainCollectionLayout.ElementType.superHeader.rawValue {
            let header: GalaxyBrainHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
            header.backgroundColor = .blue
            header.text = "SuperHeaderSection\n\(kind) - \(indexPath)"
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForSuperHeaderInSection section: Int) -> CGSize? {
        CGSize(width: UIScreen.main.bounds.width, height: 70)
    }
}

final class HeaderlessSection: Section {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalaxyBrainCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = .green
        return cell
    }

    func numberOfItemsInSection() -> Int {
        5
    }

    func register(_ collectionView: UICollectionView) {
        collectionView.register(GalaxyBrainCell.self)
    }
}
final class GalaxyBrainCell: UICollectionViewCell {}
final class GalaxyBrainHeader: UICollectionReusableView {

    var text: String = "" {
        didSet {
            label.text = text
        }
    }

    let label: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(label)
        addConstraints([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
