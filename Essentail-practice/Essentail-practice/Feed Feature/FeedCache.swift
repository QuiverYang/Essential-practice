//
//  FeedCache.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/5/9.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
    
}
