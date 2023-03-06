//
//  FeedImageViewModelData.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/3/6.
//

struct FeedImageViewModelData<Image> {
    let description: String?
    let location: String?
    
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
