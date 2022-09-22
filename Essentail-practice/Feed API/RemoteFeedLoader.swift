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
        client.get(from:url) { result in
            switch result {
            case let .success(data, res):
//                do {
//                    let items = try FeedItemsMapper.map(data, res)
//                    completion(.success(items))
//                } catch {
//                    completion(.failure(.invalidData))
//                }
                completion(self.map(data: data, response: res))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    private func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}




