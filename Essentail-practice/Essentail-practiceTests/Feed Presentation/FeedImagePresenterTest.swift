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
    
    init(view: any FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage){
        view.display(FeedImageViewModelData(description: model.description,
                                            location: model.location,
                                            image: nil,
                                            isLoading: true,
                                            shouldRetry: false))
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
    
    
    
    // MARK: - Helpers
    final class ViewSpy: FeedImageView{

        var messages = [FeedImageViewModelData]()
        
        func display(_ viewModel: FeedImageViewModelData) {
            messages.append(viewModel)
        }
            
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
}


