//
//  DiffableDataSource+CollectionView.swift
//  DiffableDatasource
//
//  Created by JoSoJeong on 2022/05/10.
//

import Foundation
import UIKit

class CollectionViewDiffableDataSourceContoller: UIViewController {
    enum Section: CaseIterable {
        case main
    }
    
    struct Song: Hashable {
        var title: String
        var singer: String
        var identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Song, rhs: Song) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        func contains(_ filter: String?) -> Bool {
            guard let filterText = filter else { return true }
            if filterText.isEmpty { return true }
            let lowercasedFilter = filterText.lowercased()
            return title.lowercased().contains(lowercasedFilter)
        }
        
    }
    
    let searchBar = UISearchBar(frame: .zero)
    var songCollectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Song>!
    let songs: [Song] = [Song(title: "데리러 가", singer: "샤이니"), Song(title: "Bad Boy", singer: "Christopher"), Song(title: "Bad", singer: "Christopher"), Song(title: "드라마", singer: "아이유"), Song(title: "Love Dive", singer: "아이브"), Song(title: "좋을텐데", singer: "성시경"), Song(title: "Strawberries & Cigarettes", singer: "Troye Sivan"), Song(title: "좋을텐데", singer: "성시경")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        self.performQuery(with: nil)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(88))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
        return layout
    }
    
    func configureHierarchy(){
        view.backgroundColor = .systemBackground
        let layout = createLayout()
        var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        view.addSubview(searchBar)

        let views = ["cv": collectionView, "searchBar": searchBar]
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[searchBar]-20-[cv]|", options: [], metrics: nil, views: views))
        constraints.append(searchBar.topAnchor.constraint(
            equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0))
        NSLayoutConstraint.activate(constraints)
        songCollectionView = collectionView
    }
}

extension CollectionViewDiffableDataSourceContoller {
    private func configureDataSource(){
        let cellRegistration = UICollectionView.CellRegistration<SongCollectionViewCell, Song> {(cell, indexPath, song) in
            cell.titleLabel.text = song.title
            cell.singerLabel.text = song.singer
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Song>(collectionView: songCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Song) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
    }
    
    func performQuery(with filter: String?) {
        let filteredSongs = songs.filter { $0.title.hasPrefix(filter ?? "" ) }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Song>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredSongs)
        dataSource.apply(snapshot, animatingDifferences: true)
        searchBar.delegate = self
    }
    
    
}

extension CollectionViewDiffableDataSourceContoller: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performQuery(with: searchText)
    }
}

