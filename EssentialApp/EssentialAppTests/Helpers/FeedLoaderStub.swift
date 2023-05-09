//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/5/9.
//

import Foundation
import Essentail_practice

class FeedLoaderStub: FeedLoader {
    var result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
