//
//  FeedStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/24.
//

import Foundation
public enum RetriveCacheFeedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    typealias RetrieveCompletion = (RetriveCacheFeedResult)->Void
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}


