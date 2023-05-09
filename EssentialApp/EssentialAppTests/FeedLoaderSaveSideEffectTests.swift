//
//  FeedLoaderSaveSideEffectTests.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/5/9.
//
import Foundation
import XCTest
import Essentail_practice

class FeedLoaderCacheDecorator: FeedLoader {
    var decoratee: FeedLoader?

    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee?.load(completion: completion)
    }
    
    
}


final class FeedLoaderSaveSideEffectTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        
        let loader = FeedLoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
}