//
//  NewsRepository.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import Combine
import Foundation

struct NewsRepository {
    /// サーバからデータを取得する
    static func fetchDataFromServer(paging: Paging? = nil) -> Future<(newsList: [News], paging: Paging), ApiError> {
        Future<(newsList: [News], paging: Paging), ApiError> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // 5%の確率で通信を失敗させる
                if Int.random(in: 0..<100) < 5 {
                    let error = ApiError(title: "通信に失敗しました",
                                         description: "通信環境の良い場所で再度お試しください")
                    promise(.failure(error))
                }

                let currentPaging = paging ?? Paging(hasNext: true, currentPage: 0)
                let fetchedPaging: Paging = .init(hasNext: currentPaging.currentPage < 10,
                                                  currentPage: currentPaging.currentPage + 1)
                let fetchedNewsList = generateDummyNewsList(currentPaging: currentPaging)

                promise(.success((newsList: fetchedNewsList, paging: fetchedPaging)))
            }
        }
    }

    private static func generateDummyNewsList(currentPaging: Paging) -> [News] {
        /// ニュースの件数は1ページあたり15件とする
        let numOfNewsPerPage: Int = 15
        let firstItemIndex = currentPaging.currentPage * numOfNewsPerPage
        let lastItemIndex = currentPaging.currentPage * numOfNewsPerPage + numOfNewsPerPage
        return (firstItemIndex..<lastItemIndex).map { generateDummyNews(index: $0) }
    }

    /// - index: 何件目のニュースか
    private static func generateDummyNews(index: Int) -> News {
        let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
        return News(headline: "ニュース\(index)", caption: "キャプション\(index)", publishedAt: date)
    }
}
