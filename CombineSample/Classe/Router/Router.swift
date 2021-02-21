//
//  Router.swift
//  CombineSample
//
//  Created by zrn_ns on 2021/02/21.
//

import UIKit

final class Router {
    weak var viewController: UIViewController?

    func showError(_ error: ApiError) {
        let alertController = UIAlertController(title: error.title,
                                                message: error.description,
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "閉じる",
                                          style: .cancel,
                                          handler: nil)
        alertController.addAction(dismissAction)

        viewController?.present(alertController, animated: true, completion: nil)
    }
}
