//
//  FeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult) -> Void)
}
