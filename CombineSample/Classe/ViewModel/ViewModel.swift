//
//  ViewModel.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import Combine
import Foundation
import SwiftUI

final class ViewModel {
    @Published private(set) var newsList: [News] = []
    @Published private(set) var paging: Paging? = nil {
        didSet {
            needsToShowPagingCell = paging?.hasNext ?? false
        }
    }
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var needsToShowPagingCell: Bool = false

    func viewDidLoad(vc: UIViewController) {
        router = Router()
        router?.viewController = vc

        fetchNewsFromServer()
    }

    func willDisplayNews(_ news: News) {
        if newsList.count - newsList.lastIndex(of: news)! < 5 {
            fetchNewsFromServer()
        }
    }

    func willDisplayPagingCell() {
        fetchNewsFromServer()
    }

    @objc func pulledDownRefreshControl() {
        paging = nil
        newsList = []
        fetchNewsFromServer()
    }

    private var router: Router?
    private var cancellables: Set<AnyCancellable> = []

    private func fetchNewsFromServer() {
        guard !isLoading else { return }
        isLoading = true
        NewsRepository.fetchDataFromServer(paging: paging).sink { [weak self] completion in
            guard let _self = self else { return }

            _self.isLoading = false

            switch completion {
            case .failure(let error):
                _self.router?.showError(error)
            case .finished:
                break
            }

        } receiveValue: { [weak self] (newsList: [News], paging: Paging) in
            self?.newsList.append(contentsOf: newsList)
            self?.paging = paging

        }.store(in: &cancellables)
    }
}
