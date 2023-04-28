//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import XCTest
import Essentail_practice

final class PrimaryLoaderWithFallbackComposite: FeedLoader {
    var primary: FeedLoader
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class RemoteFeedLoaderWithLocalFallbackCompositesTests: XCTestCase {
    
    func test_load_deliversRemoteFeedOnRemoteLoaderSuccess() {
        
        let remoteFeed = uniqeFeed()
        let localFeed = uniqeFeed()
        
        let localLoader = LoaderStub(result: .success(localFeed))
        let remoteLoader = LoaderStub(result: .success(remoteFeed))
        let composer = PrimaryLoaderWithFallbackComposite(primary: remoteLoader, fallback: localLoader)
        
        let exp = expectation(description: "wait for load")
        composer.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, remoteFeed)
            case .failure:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    private func uniqeFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "", location: "", url: anyURL())]
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "some-url")!
    }
                                     
    
    private class LoaderStub: FeedLoader {
        var result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
        
        
    }
}
