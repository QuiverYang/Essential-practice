//
//  FeedPresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/17.
//

import XCTest
import Essentail_practice

class FeedPresenter  {
    init(errorView: FeedErrorView, loadingView: FeedLoadingView) {
        self.errorView = errorView
        self.loadingView = loadingView
        
    }
    
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    
    func didStartLoadingFeed() {
        errorView.display(.noError())
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
    }
}

struct FeedErrorViewModelData {
    var message: String?
    
    static func noError() -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: .none)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModelData)
}

struct FeedLoadingViewModelData {
    let isLoading: Bool
}

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModelData)
}

struct FeedViewModelData {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModelData)
}


final class FeedPresenterTest: XCTestCase {

    func test_FeedDoesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        
        XCTAssertTrue(view.messages.isEmpty, "Expect no view message")
    }
    
    func test_didStartLoadingFeed_displayNoErrorMessageAndStartsLoading() {
        let (presneter, view) = makeSUT()
        
        presneter.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage:.none), .display(isLoading: true)])
    }
    
    
    private class ViewSpy: FeedErrorView,  FeedLoadingView{
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        func display(_ viewModel: FeedErrorViewModelData) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModelData) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        
        
    }
    
    // Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(errorView: view, loadingView: view)
        trackForMemoryLeaks(presenter)
        trackForMemoryLeaks(view)
        return (presenter, view)
    
        
    }

}
