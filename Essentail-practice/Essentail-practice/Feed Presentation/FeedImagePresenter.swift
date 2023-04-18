//
//  FeedImagePresenter.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/18.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModelData<Image>)
}

public final class FeedImagePresenter<View: FeedImageView,Image> where View.Image == Image{
    
    private let view: View
    private let imageTransformer: (Data) -> Image?

    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage){
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: true,
                                            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage){
        let image = imageTransformer(data)
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: image,
                                            isLoading: false,
                                            shouldRetry: image == nil))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: false,
                                            shouldRetry: true))
    }
}

public struct FeedImageViewModelData<Image> {
    public let description: String?
    public let location: String?
    
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
    
}
