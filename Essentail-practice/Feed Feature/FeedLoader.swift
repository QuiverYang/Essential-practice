//
//  FeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/15.
//

import Foundation


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage],Error>
    func load(completion : @escaping (Result) -> Void)
}
