//
//  LocalFeedImageDataLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/25.
//


public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    
    private final class Task: FeedImageDataLoaderTask {
        
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func cancel() {
            preventFurtherCompletions()
        }
        
        func complete(with result: FeedImageDataStore.Result) {
            completion?(result)
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    public enum Error: Swift.Error {
        case fail
        case notFound
    }
    private var store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> Essentail_practice.FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url){ [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure:
                task.complete(with: .failure(Error.fail))
            case let .success(data):
                guard data != nil else {
                    task.complete(with: .failure(Error.notFound))
                    return
                }
                task.complete(with: .success(data))
                return
            }
        }
        return task
    }
    

}
