//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import XCTest
import Essentail_practice

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        
    }
    
    struct Task: FeedImageDataLoaderTask{
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return Task()
    }
    
    
}


final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_initDoesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    //Helpers:
    
    final class LoaderSpy: FeedImageDataLoader {
        
        var loadedURLs = [URL]()
        
        struct Task: FeedImageDataLoaderTask{
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            return Task()
        }
        
        
    }
}
