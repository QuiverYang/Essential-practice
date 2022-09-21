//
//  RemoteFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/16.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol HttpClient {
    func get(from url: URL, completion : @escaping (HTTPClientResult) -> Void)
}
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
                if res.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
        
    }
}
private struct Root : Decodable {
    let items : [FeedItem]
    
}
