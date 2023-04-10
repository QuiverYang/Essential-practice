//
//  WeakRefVirtualProxy.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/10.
//

import Foundation
import Essentail_practice
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModelData) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImageViewModelData<UIImage>) {
        object?.display(viewModel)
    }
}
