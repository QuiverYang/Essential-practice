//
//  FeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage],Error>

public protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult) -> Void)
}
