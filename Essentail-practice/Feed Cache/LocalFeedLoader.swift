//
//  LocalFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/24.
//

import Foundation

public final class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate: () -> Date
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(images, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve{ result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case .empty:
                completion(.success([]))
            case let .found(feed: feeds, _):
                completion(.success(feeds.toModels()))
            }
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)}
    }
}

extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL)}
    }
}

