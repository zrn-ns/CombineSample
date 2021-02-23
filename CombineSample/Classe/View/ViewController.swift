//
//  ViewController.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import Combine
import UIKit

private let NewsCellClassName = String(describing: NewsCollectionViewCell.self)
private let NewsCellIdentifier: String = NewsCellClassName

private let PagingCellClassName = String(describing: PagingCollectionViewCell.self)
private let PagingCellIdentifier = PagingCellClassName

class ViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case news
        case paging
    }

    enum Item: Hashable {
        case news(news: News)
        case paging
    }

    var viewModel: ViewModel = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewDidLoad(vc: self)
        setupSubscription()
    }

    // MARK: - private

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = collectionViewDataSource
            collectionView.collectionViewLayout = Self.createLayout(collectionViewWidth: collectionView.bounds.width)
            collectionView.refreshControl = refreshControl
            collectionView.register(UINib(nibName: NewsCellClassName, bundle: nil), forCellWithReuseIdentifier: NewsCellIdentifier)
            collectionView.register(PagingCollectionViewCell.self, forCellWithReuseIdentifier: PagingCellIdentifier)
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(viewModel, action: #selector(ViewModel.pulledDownRefreshControl), for: .valueChanged)
        return control
    }()

    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
        guard let _self = self else { return nil }

        switch item {
        case .news(let news):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCellIdentifier, for: indexPath) as? NewsCollectionViewCell else {
                fatalError("セルの取得に失敗しました")
            }
            cell.set(.init(news: news))
            return cell

        case .paging:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellIdentifier, for: indexPath) as? PagingCollectionViewCell else {
                fatalError("セルの取得に失敗しました")
            }

            cell.startAnimating()
            return cell
        }
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.news])
        snapshot.appendItems(viewModel.newsList.map({ .news(news: $0) }), toSection: .news)

        if viewModel.needsToShowPagingCell {
            snapshot.appendSections([.paging])
            snapshot.appendItems([.paging], toSection: .paging)
        }

        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func setupSubscription() {
        viewModel.$newsList.removeDuplicates().sink { [weak self] _ in
            self?.updateDataSource()
        }.store(in: &cancellables)

        viewModel.$isLoading.removeDuplicates().sink { [weak self] isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading

            if !isLoading {
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)

        viewModel.$needsToShowPagingCell.removeDuplicates().sink { [weak self] _ in
            self?.updateDataSource()
        }.store(in: &cancellables)
    }

    private static func createLayout(collectionViewWidth: CGFloat) -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(50))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = (collectionView.dataSource as? UICollectionViewDiffableDataSource<Section, Item>)?.itemIdentifier(for: indexPath) else {
            fatalError("不正な状態")
        }

        switch item {
        case .news(let news):
            viewModel.willDisplayNews(news)

        case .paging:
            viewModel.willDisplayPagingCell()
        }
    }
}
