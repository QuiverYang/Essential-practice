//
//  FeedImageCellController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//


import UIKit
import Essentail_practice

final class FeedImageCellController {
    
    private let model: FeedImage
    
    private var task: FeedImageDataLoaderTask?
    
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader){
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        let loadImage = { [weak cell, weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: self.model.url){ [weak cell] result in
                // Result 寫法1
                //            switch result {
                //            case .success(let data):
                //                cell?.feedImageView.image = UIImage(data: data)
                //            case .failure: break
                //            }
                // Result 寫法2
                //            if case let Result.success(data) = result {
                //                cell?.feedImageView.image = UIImage(data: data)
                //            }
                // Result 寫法3
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url){ _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
