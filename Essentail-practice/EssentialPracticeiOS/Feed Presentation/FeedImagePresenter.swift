//
//  FeedImagePresenter.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/21.
//

import Foundation
import Essentail_practice

struct FeedImageViewModelData<Image> {
    let description: String?
    let location: String?
    
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModelData<Image>)
}

final class FeedImagePresenter<View: FeedImageView,Image> where View.Image == Image{
    
    private let imageTransformer: (Data) -> Image?
    private let view: View


    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.imageTransformer = imageTransformer
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage){
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: true,
                                            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage){
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: image,
                                            isLoading: false,
                                            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: false,
                                            shouldRetry: true))
    }

}
