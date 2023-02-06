//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/2/6.
//

import Foundation
import Essentail_practice
import EssentialPracticeiOS

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    

    // MARK: FeedLoader
    
    var loadCallCount : Int {
        return completions.count
    }
    
    private var completions = [(FeedLoader.Result) -> Void]()
    
    func load(completion : @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        completions[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        completions[index](.failure(error))
    }
    
    // MARK: FeedImageDataLoader
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let canelCallback: () -> Void
        func cancel() {
            canelCallback()
        }
    }
    
    var loadedImageURLs : [URL] {
        return imageRequests.map{$0.url}
    }
    
    private(set) var canceledImageURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy {[weak self] in self?.canceledImageURLs.append(url)}
    }
    
    func completeImageLoading(with imageData: Data = Data(),at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
