//
//  FeedItemsMapper.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/22.
//

import Foundation


// api model
internal struct RemoteFeedItem : Decodable{
    public let id : UUID
    public let description : String?
    public let location : String?
    public let image : URL
}

internal class FeedItemsMapper {
    private struct Root : Decodable {
        let items : [RemoteFeedItem]
    }
        
    private static var OK_200 : Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}
