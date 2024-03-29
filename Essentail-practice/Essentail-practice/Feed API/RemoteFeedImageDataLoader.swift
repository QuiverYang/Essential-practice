//
//  RemoteFeedImageDataLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/24.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    let client: HTTPClient
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result{
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            case let .success((data, response)):
                if response.isOK && !data.isEmpty{
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }

            }
//            task.complete(with: result
//                            .mapError { _ in Error.connectivity }
//                            .flatMap { (data, response) in
//                                let isValidResponse = response.statusCode == 200 && !data.isEmpty
//                                return isValidResponse ? .success(data) : .failure(Error.invalidData)
//                            })
        }
        return task
    }
}
