//
//  MainQueueDispatchDecorator.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/10.
//

import Foundation
import Essentail_practice
import EssentialPracticeiOS

class MainThreadDispatchDecorator<T>{
    let decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }

    
}

extension MainThreadDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            guard self != nil else { return }
            self?.dispatch{
                completion(result)
            }
        }
    }
}

extension MainThreadDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            guard self != nil else { return }
            self?.dispatch{
                completion(result)
            }
        }
    }

    
}
