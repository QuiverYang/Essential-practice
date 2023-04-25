//
//  FeedImageDataStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/25.
//

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
}
