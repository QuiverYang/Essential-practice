//
//  FeedImagePresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/18.
//

import Foundation

import XCTest

final class FeedImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class FeedImagePresenterTest: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    final private class ViewSpy {
        var messages = [Any]()
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
}


