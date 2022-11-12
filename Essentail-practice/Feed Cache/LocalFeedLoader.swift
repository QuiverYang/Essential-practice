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
    private let calendar = Calendar(identifier: .gregorian)
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    private var maxCacheAgeInDay : Int { return 7}
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
        store.retrieve{ [unowned self] result in
            switch result {
            case let .failure(error):
                store.deleteCacheFeed { _ in }
                completion(.failure(error))
            case let .found(feed: feeds, timestamp) where self.validate(timestamp):
                completion(.success(feeds.toModels()))
            case .found:
                store.deleteCacheFeed { _ in }
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
            
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDay, to: timestamp) else {return false}
        return currentDate() < maxCacheAge
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

