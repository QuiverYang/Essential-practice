//
//  RemoteFeedItem.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/26.
//

import Foundation
// data transfer object (DTO), API model for now
internal struct RemoteFeedItem : Decodable{
    public let id : UUID
    public let description : String?
    public let location : String?
    public let image : URL
}
