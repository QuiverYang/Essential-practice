//
//  RemoteFeedLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/16.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL, completion : @escaping (Error) -> Void)
}
final public class RemoteFeedLoader {
    let url : URL
    let client : HttpClient
    
    public enum Error : Swift.Error{
        case connectivity
    }
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    public func load(completion : @escaping (Error) -> Void = {_ in}){
//        completion(.connectivity)
        client.get(from:url) { error in
            completion(.connectivity)
        }
        
    }
}
