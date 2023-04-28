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
    var fallback: FeedLoader
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result{
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

final class RemoteFeedLoaderWithLocalFallbackCompositesTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        
        let primaryFeed = uniqeFeed()
        let fallbackFeed = uniqeFeed()
        
        let localLoader = LoaderStub(result: .success(fallbackFeed))
        let remoteLoader = LoaderStub(result: .success(primaryFeed))
        let composer = PrimaryLoaderWithFallbackComposite(primary: remoteLoader, fallback: localLoader)
        
        let exp = expectation(description: "wait for load")
        composer.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, primaryFeed)
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")

            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqeFeed()
        
        let fallback = LoaderStub(result: .success(fallbackFeed))
        let primary = LoaderStub(result: .failure(anyNSError()))
        let composer = PrimaryLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        
        let exp = expectation(description: "wait for load")
        composer.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, fallbackFeed)
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
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
