//
//  FeedItemsMapper.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/22.
//

import Foundation



class FeedItemsMapper {
    private struct Root : Decodable {
        let items : [RemoteFeedItem]
    }
        
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}
