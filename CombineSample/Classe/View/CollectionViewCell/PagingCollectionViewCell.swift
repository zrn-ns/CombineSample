//
//  PagingCollectionViewCell.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import UIKit

final class PagingCollectionViewCell: UICollectionViewCell {

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    private func commonInit() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        addConstraints([
            centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
            centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor),
            heightAnchor.constraint(equalToConstant: 70).withPriority(.defaultLow)
        ])

    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
}
