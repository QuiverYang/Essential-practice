//
//  FeedItem.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation

public struct FeedItem : Equatable{
    public init(id : UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    public let id : UUID
    public let description : String?
    public let location : String?
    public let imageURL : URL
}

extension FeedItem: Decodable {
    private enum CodingKeys : String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
