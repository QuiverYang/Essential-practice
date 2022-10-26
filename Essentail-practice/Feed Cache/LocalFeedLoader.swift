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
    
    public func load() {
        store.retrieve()
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

