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
    
    init(model: FeedImage,imageLaoder: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLaoder
        self.imageTransformer = imageTransformer
    }
    var description: String? {
        return model.description
    }
    var location: String? {
        return model.location
    }
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url){ [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
}
