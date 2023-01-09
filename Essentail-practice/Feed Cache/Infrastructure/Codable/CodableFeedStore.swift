//
//  CodableFeedStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/11/25.
//

import Foundation

public class CodableFeedStore :FeedStore{
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage: Codable {
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            imageURL = image.imageURL
        }
        private let id : UUID
        private let description : String?
        private let location : String?
        private let imageURL : URL
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let storeURL : URL
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
        
        
    }
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        // 在這裡的storeURL是 value type 所以可以不用擔心retain cycle
        // 可以直接將直copy取出後放入closure中使用，該closure不擁有self！
//        let storeURL = self.storeURL
        queue.async(flags: .barrier) {  [storeURL] in
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
}
