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

    static func calculateHeight(for width: CGFloat) -> CGFloat {
        let prototypingCell = UINib(nibName: String(describing: Self.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! Self
        return prototypingCell.contentView
            .systemLayoutSizeFitting(CGSize(width: width, height: .zero),
                                     withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            .height
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
