//
//  FeedViewAdapter.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/10.
//

import Foundation
import Essentail_practice
import UIKit
import EssentialPracticeiOS

final class FeedViewAdaptor: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: Essentail_practice.FeedViewModelData) {
        controller?.display(viewModel.feed.map { model in
            let adpator = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adpator)
            adpator.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        })
    }
}
