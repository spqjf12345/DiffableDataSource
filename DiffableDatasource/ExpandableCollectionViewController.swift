//
//  ExpandableTableViewController.swift
//  DiffableDatasource
//
//  Created by JoSoJeong on 2022/05/12.
//

import Foundation
import UIKit

class ExpandableCollectionViewController: UIViewController {
    enum Section {
        case main
    }
    
    class ListItem: Hashable {
        let title: String
        let subitems: [ListItem]
        let outlineViewController: UIViewController.Type?

        init(title: String,
             viewController: UIViewController.Type? = nil,
             subitems: [ListItem] = []) {
            self.title = title
            self.subitems = subitems
            self.outlineViewController = viewController
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: ListItem, rhs: ListItem) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        private let identifier = UUID()
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>! = nil
    var outlineCollectionView: UICollectionView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Modern Collection Views"
        configureCollectionView()
        configureDataSource()
    }
    
    lazy var lists: [ListItem] = [ListItem(title: "CollectionView", subitems: [ListItem(title: "song diffable data source")]), ListItem(title: "TableView", subitems: [ListItem(title: "test"), ListItem(title: "test1")])]
    
}
extension ExpandableCollectionViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemGroupedBackground
        self.outlineCollectionView = collectionView
        collectionView.delegate = self
    }
    
    func configureDataSource(){
        let containerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ListItem> { (cell, indexPath, menuItem) in
            // Populate the cell with our item description.
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = menuItem.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration
            
            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ListItem> { cell, indexPath, menuItem in
            // Populate the cell with our item description.
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = menuItem.title
            cell.contentConfiguration = contentConfiguration
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: outlineCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: ListItem) -> UICollectionViewCell? in
            // Return the cell.
            if item.subitems.isEmpty {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: containerCellRegistration, for: indexPath, item: item)
            }
        }

        // load our initial data
        let snapshot = initialSnapshot()
        self.dataSource.apply(snapshot, to: .main, animatingDifferences: false)
    }
    
    func configureLayout() -> UICollectionViewLayout {
      let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
      let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        return layout
    }
    
    //section snapshot
    func initialSnapshot() -> NSDiffableDataSourceSectionSnapshot<ListItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()

        func addItems(_ menuItems: [ListItem], to parent: ListItem?) {
            snapshot.append(menuItems, to: parent)
            for menuItem in menuItems where !menuItem.subitems.isEmpty {
                addItems(menuItem.subitems, to: menuItem)
            }
        }
        
        addItems(lists, to: nil)
        return snapshot
    }
}

extension ExpandableCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let viewController = menuItem.outlineViewController {
            navigationController?.pushViewController(viewController.init(), animated: true)
        }
        
    }
}
