//
//  FeedImagePresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/18.
//

import Foundation

import XCTest
import Essentail_practice

final class FeedImagePresenter {
    private let view: any FeedImageView
    private let imageTransformer: (Data) -> Any?

    
    init(view: any FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
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

struct FeedImageViewModelData {
    let description: String?
    let location: String?
    
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
}

protocol FeedImageView {
    
    func display(_ viewModel: FeedImageViewModelData)
}

final class FeedImagePresenterTest: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImage_displayLoaingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImage_displayRetryImageOnTransformFail() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil})
        let image = uniqueImage()
        let data = Data("invalid data".utf8)
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    
    
    
    // MARK: - Helpers
    final class ViewSpy: FeedImageView{

        var messages = [FeedImageViewModelData]()
        
        func display(_ viewModel: FeedImageViewModelData) {
            messages.append(viewModel)
        }
            
    }
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil}, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
}


