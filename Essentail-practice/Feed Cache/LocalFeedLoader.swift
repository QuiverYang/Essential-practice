//
//  LocalFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/24.
//

import Foundation

class FeedCachePolicy {
    
    init(currentDate : @escaping ()->Date) {
        self.currentDate = currentDate
    }
    
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    private var maxCacheAgeInDay : Int { return 7}
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDay, to: timestamp) else {return false}
        return currentDate() < maxCacheAge
    }
}

public final class LocalFeedLoader : FeedLoader{
    private let store : FeedStore
    private let cachePolicy : FeedCachePolicy
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
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
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve{ [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed: feeds, timestamp) where self.cachePolicy.validate(timestamp):
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
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
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

