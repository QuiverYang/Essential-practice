//
//  EssentialPracticeiOSTests.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/1/16.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    class LoaderSpy {
        private (set) var loadCallCount = 0
    }

}
