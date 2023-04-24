//
//  RemoteFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/16.
//

import Foundation


final public class RemoteFeedLoader : FeedLoader {
    let url : URL
    let client : HTTPClient
    
    public enum Error : Swift.Error{
        case connectivity
        case invalidData
    }
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion : @escaping (Result) -> Void){
        client.get(from:url) {[weak self] result in
            // check if self is still exist
            // if not, return to aviod unexpected client get been reiggered
            guard self != nil else {return}
            switch result {
            case let .success((data, res)):
                completion(RemoteFeedLoader.map(data, res))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
    }
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items.toModels())
        } catch {
            return .failure(Error.invalidData)
        }
    }
    
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}



