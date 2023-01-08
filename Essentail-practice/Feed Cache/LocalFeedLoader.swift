//
//  LocalFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/24.
//

import Foundation

public final class LocalFeedLoader : FeedLoader{
    private let store : FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    
    
}
extension LocalFeedLoader {
    public typealias SaveResult = Error?

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
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}
extension LocalFeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve{ [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed: feeds, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feeds.toModels()))
            case .found, .empty:
                completion(.success([]))
            @unknown default: break

            }
        }
    }
    
}
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve{ [weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure:
                self.store.deleteCacheFeed{_ in }
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCacheFeed { _ in }
            case .found, .empty: break
            }
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

