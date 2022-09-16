//
//  RemoteFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/16.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL)
}
public class RemoteFeedLoader {
    let client : HttpClient
    let url : URL
    public init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    public func load(){
        client.get(from:url)
    }
}
