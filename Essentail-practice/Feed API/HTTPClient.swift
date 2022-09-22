//
//  HTTPClient.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/9/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol HttpClient {
    func get(from url: URL, completion : @escaping (HTTPClientResult) -> Void)
}
