//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import XCTest
import Essentail_practice
import EssentialApp


final class RemoteFeedLoaderWithLocalFallbackCompositesTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqeFeed()
        let fallbackFeed = uniqeFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqeFeed()
        
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    //Helpers:
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result) -> PrimaryLoaderWithFallbackComposite {
        let fallback = LoaderStub(result: fallbackResult)
        let primary = LoaderStub(result: primaryResult)
        let composer = PrimaryLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(fallback)
        trackForMemoryLeaks(primary)
        trackForMemoryLeaks(composer)
        return composer
    }
    
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
                
        wait(for: [exp], timeout: 1.0)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
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
