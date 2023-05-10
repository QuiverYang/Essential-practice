//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import XCTest
import Essentail_practice
import EssentialApp


final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    //Helpers:
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result) -> FeedLoaderWithFallbackComposite {
        let fallback = FeedLoaderStub(result: fallbackResult)
        let primary = FeedLoaderStub(result: primaryResult)
        let composer = FeedLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(fallback)
        trackForMemoryLeaks(primary)
        trackForMemoryLeaks(composer)
        return composer
    }
    
}
