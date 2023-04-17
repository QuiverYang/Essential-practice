//
//  FeedItem.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation

public struct FeedImage : Hashable{
    public init(id : UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
    public let id : UUID
    public let description : String?
    public let location : String?
    public let url : URL
}

