//
//  URLSessionHTTPClient.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/29.
//

import Foundation
public class URLSessionHTTPClient: HttpClient {
    public init() {}
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
