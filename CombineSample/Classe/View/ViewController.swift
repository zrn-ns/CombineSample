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

class ViewController: UIViewController {

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
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width,
                      height: NewsCollectionViewCell.calculateHeight(for: width))
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.newsList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCellIdentifier, for: indexPath) as? NewsCollectionViewCell else {
            fatalError("セルの取得に失敗しました")
        }
        let news = viewModel.newsList[indexPath.row]
        cell.set(.init(news: news))
        return cell
    }
}
