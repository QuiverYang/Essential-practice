//
//  FeedImageDataStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/25.
//

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
