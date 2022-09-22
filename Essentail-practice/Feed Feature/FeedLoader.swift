//
//  FeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error : Swift.Error
    func load(completion : @escaping (LoadFeedResult<Error>) -> Void)
}
