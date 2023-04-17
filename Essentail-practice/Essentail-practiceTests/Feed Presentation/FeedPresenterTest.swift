//
//  FeedPresenterTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/17.
//

import XCTest

class FeedPresenter  {
    init(view: Any) {
        
    }
}


final class FeedPresenterTest: XCTestCase {

    func test_FeedDoesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        
        XCTAssertTrue(view.messages.isEmpty, "Expect no view message")
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }
    
    // Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(view: view)
        trackForMemoryLeaks(presenter)
        trackForMemoryLeaks(view)
        return (presenter, view)
    
        
    }

}
