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

    enum Section: Int {
        case news
        case paging
    }

    enum Item: Hashable {
        case news(news: News)
        case paging
    }

    let viewModel: ViewModel = .init()

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewDidLoad(vc: self)
        setupSubscription()
    }

    // MARK: - outlet

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

    // MARK: - private

    private var cancellables: Set<AnyCancellable> = []

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(viewModel, action: #selector(ViewModel.pulledDownRefreshControl), for: .valueChanged)
        return control
    }()

    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
        switch item {
        case .news(let news):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCellIdentifier, for: indexPath) as! NewsCollectionViewCell
            cell.set(.init(news: news))
            return cell

        case .paging:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCellIdentifier, for: indexPath) as! PagingCollectionViewCell
            cell.startAnimating()
            return cell
        }
    }

    /// イベントの購読の登録を行う
    private func setupSubscription() {
        // ニュース一覧
        viewModel.$newsList.receive(on: DispatchQueue.main).removeDuplicates().sink { [weak self] _ in
            self?.updateDataSource()
        }.store(in: &cancellables)

        // ページングセル
        viewModel.$needsToShowPagingCell.receive(on: DispatchQueue.main).removeDuplicates().sink { [weak self] _ in
            self?.updateDataSource()
        }.store(in: &cancellables)

        // ロード中表示
        viewModel.$isLoading.receive(on: DispatchQueue.main).removeDuplicates().sink { [weak self] isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading

            if !isLoading {
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)
    }

    /// CollectionViewのLayoutを作成する
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

    /// CollectionViewのデータソースを更新する
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
