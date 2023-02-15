//
//  FeedImageViewModel.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/15.
//

import Foundation
import Essentail_practice

final class FeedImageViewModel<Image> {
    
    typealias Observer<T> = (T) -> Void
    
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private var task: FeedImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?


    init(imageLoader: FeedImageDataLoader, model: FeedImage,  imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformer = imageTransformer
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoaded: Observer<Image>?
    var onRetryStateChange: Observer<Bool>?
    var onImageLoadingStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onRetryStateChange?(false)
        task = imageLoader.loadImageData(from: model.url){[weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoaded?(image)
        } else {
            onRetryStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelLoad() {
        task?.cancel()
    }

}
