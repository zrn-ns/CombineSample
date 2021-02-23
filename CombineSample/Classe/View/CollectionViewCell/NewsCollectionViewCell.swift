//
//  NewsCollectionViewCell.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import UIKit

final class NewsCollectionViewCell: UICollectionViewCell {

    struct ViewModel {
        let headline: String
        let caption: String
        let publishDate: Date

        var formattedPublishDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: publishDate)
        }

        init(news: News) {
            headline = news.headline
            caption = news.caption
            publishDate = news.publishedAt
        }
    }

    func set(_ viewModel: ViewModel) {
        self.headlineLabel.text = viewModel.headline
        self.captionLabel.text = viewModel.caption
        self.publishDateLabel.text = viewModel.formattedPublishDate
    }

    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var publishDateLabel: UILabel!
}
