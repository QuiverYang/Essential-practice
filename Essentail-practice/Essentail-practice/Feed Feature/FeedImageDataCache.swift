//
//  FeedImageDataCache.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/5/10.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Swift.Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
