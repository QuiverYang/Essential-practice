//
//  FeedErrorViewModelData.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/14.
//

import Foundation

struct FeedErrorViewModelData {
    var message: String?
    
    static func noError() -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: .none)
    }
    
    static func error(message: String) -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: message)
    }
}
