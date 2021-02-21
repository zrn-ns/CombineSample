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
    @Published var newsList: [News] = []
    @Published var paging: Paging? = nil
    @Published var isLoading: Bool = false

    func viewDidLoad(vc: UIViewController) {
        router = Router()
        router?.viewController = vc

        fetchNewsFromServer()
    }

    @objc func pulledDownRefreshControl() {
        newsList = []
        paging = nil
        fetchNewsFromServer()
    }

    private var router: Router?
    private var cancellables: Set<AnyCancellable> = []

    private func fetchNewsFromServer() {
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
