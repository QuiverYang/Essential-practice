//
//  FeedItemsMapper.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/22.
//

import Foundation

internal class FeedItemsMapper {
    private struct Root : Decodable {
        let items : [Item]
        var  feeds: [FeedItem] {
            return items.map{$0.item}
        }
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
    
    private static var OK_200 : Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.feeds)
    }
    
}