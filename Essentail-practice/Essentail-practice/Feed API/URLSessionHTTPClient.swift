//
//  URLSessionHTTPClient.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/29.
//

import Foundation
public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionHTTPClientTask: HTTPClientTask {
        let wrapped: URLSessionTask
        func cancel() {
            wrapped.cancel()
        }
    }
    
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            // result builder的寫法 swift 5.4後
//            completion(Result {
//                if let error = error {
//                    throw error
//                } else if let data = data, let response = response as? HTTPURLResponse{
//                    return (data, response)
//                } else {
//                     throw UnexpectedValuesRepresentation()
//                }
//            })
            let result: HTTPClient.Result
                    
            if let error = error {
                result = .failure(error)
            } else if let data = data, let response = response as? HTTPURLResponse {
                result = .success((data, response))
            } else {
                result = .failure(UnexpectedValuesRepresentation())
            }
            
            completion(result)
        }
        task.resume()
        return URLSessionHTTPClientTask(wrapped: task)
    }
}
