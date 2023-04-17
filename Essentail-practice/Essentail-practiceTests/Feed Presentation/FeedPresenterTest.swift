//
//  FeedPresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/17.
//

import XCTest
import Essentail_practice

class FeedPresenter  {
    init(errorView: FeedErrorView, loadingView: FeedLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
        
    }
    
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    static var errorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "load error message")
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError())
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
        errorView.display(.error(message: FeedPresenter.errorMessage))
    }
}

struct FeedErrorViewModelData {
    var message: String?
    
    static func noError() -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: message)
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
    
    func test_didFinishLoadingFeed_displayFeedAndStopLoading() {
        let (presneter, view) = makeSUT()
        let feed = uniqueImageFeed().models
        
        presneter.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)])
    }
    
    func test_didFinishLoadingFeedWithError_displayLocalLizedErrorMessageAndStopLoading() {
        
        let (presenter, view) = makeSUT()
        
        presenter.didFinsihLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    
    
    private class ViewSpy: FeedErrorView,  FeedLoadingView, FeedView{
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        func display(_ viewModel: FeedErrorViewModelData) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModelData) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModelData) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
    }
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    
    
    // Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(errorView: view, loadingView: view, feedView: view)
        trackForMemoryLeaks(presenter)
        trackForMemoryLeaks(view)
        return (presenter, view)
    
        
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
