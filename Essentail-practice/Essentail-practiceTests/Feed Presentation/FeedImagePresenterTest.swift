//
//  FeedImagePresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/18.
//

import Foundation

import XCTest
import Essentail_practice

final class FeedImagePresenter<View: FeedImageView,Image> where View.Image == Image{
    
    private let view: View
    private let imageTransformer: (Data) -> Image?

    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
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
        let image = imageTransformer(data)
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: image,
                                            isLoading: false,
                                            shouldRetry: image == nil))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: false,
                                            shouldRetry: true))
    }
}

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
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImage_displayImageOnSuccessfulDataTransform() {
        let transformData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in  transformData})
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformData)
    }
    
    func test_DidFinishLoadingImageDataWithError_displayRetry() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    
    
    // MARK: - Helpers
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModelData<AnyImage>]()
        
        func display(_ model: FeedImageViewModelData<AnyImage>) {
            messages.append(model)
        }
    }
    
    private struct AnyImage: Equatable {}
    
    private var fail: (Data) -> AnyImage? = { _ in nil }
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil}, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
}


