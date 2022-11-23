//
//  LocalFeedImage.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/26.
//

import Foundation
public struct LocalFeedImage : Equatable{
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
