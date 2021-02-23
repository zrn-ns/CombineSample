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

    enum Sections: Int, CaseIterable {
        case news
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
            collectionView.dataSource = self
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

    private func setupSubscription() {
        viewModel.$newsList.removeDuplicates().sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &cancellables)

        viewModel.$isLoading.removeDuplicates().sink { [weak self] isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading

            if !isLoading {
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)

        viewModel.$needsToShowPagingCell.removeDuplicates().sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &cancellables)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch Sections.allCases[indexPath.section] {
        case .news:
            let width = collectionView.bounds.width
            return CGSize(width: width,
                          height: NewsCollectionViewCell.calculateHeight(for: width))

        case .paging:
            let width = collectionView.bounds.width
            return CGSize(width: width,
                          height: PagingCollectionViewCell.height)
        }
    }
}

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Sections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Sections.allCases[section] {
        case .news:
            return viewModel.newsList.count
        case .paging:
            return viewModel.needsToShowPagingCell ? 1 : 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Sections.allCases[indexPath.section] {
        case .news:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCellIdentifier, for: indexPath) as? NewsCollectionViewCell else {
                fatalError("セルの取得に失敗しました")
            }
            let news = viewModel.newsList[indexPath.row]
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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch Sections.allCases[indexPath.section] {
        case .news:
            let news = viewModel.newsList[indexPath.row]
            viewModel.willDisplayNews(news)

        case .paging:
            viewModel.willDisplayPagingCell()
        }
    }
}
