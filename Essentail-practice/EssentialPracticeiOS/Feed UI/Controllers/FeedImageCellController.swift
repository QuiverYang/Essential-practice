//
//  FeedImageCellController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//


import UIKit
import Essentail_practice

final class FeedImageCellController {
    
    
    private var viewModel: FeedImageViewModel
    
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader){
        self.viewModel = FeedImageViewModel(imageLoader: imageLoader, model: model)
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoaded = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = {[weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onRetryStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
}
