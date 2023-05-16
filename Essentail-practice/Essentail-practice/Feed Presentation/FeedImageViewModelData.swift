//
//  FeedImageViewModelData.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/18.
//

import Foundation
public struct FeedImageViewModelData<Image> {
    public let description: String?
    public let location: String?
    
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }

    
}
