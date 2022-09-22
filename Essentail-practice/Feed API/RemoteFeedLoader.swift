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
                do {
                    let items = try FeedItemsMapper.map(data, res)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
        
    }
}



class FeedItemsMapper {
    private struct Root : Decodable {
        let items : [Item]
        
    }
    // api model
    private struct Item : Decodable{
        public let id : UUID
        public let description : String?
        public let location : String?
        public let image : URL
        var item : FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200 : Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData}
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
