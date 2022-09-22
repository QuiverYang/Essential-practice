//
//  RemoteFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/16.
//

import Foundation


final public class RemoteFeedLoader {
    let url : URL
    let client : HttpClient
    
    public enum Error : Swift.Error{
        case connectivity
        case invalidData
    }
    public enum Result : Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    public func load(completion : @escaping (Result) -> Void){
        client.get(from:url) {[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success(data, res):
                completion(FeedItemsMapper.map(data, res))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }}




