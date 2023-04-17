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
        let view = ViewSpy()
        
        let _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expect no view message")
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }

}
