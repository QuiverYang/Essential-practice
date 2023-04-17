//
//  FeedErrorViewModelData.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/17.
//

import Foundation

public struct FeedErrorViewModelData {
    public var message: String?
    
    public static func noError() -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: .none)
    }
    
    public static func error(message: String) -> FeedErrorViewModelData {
        return FeedErrorViewModelData(message: message)
    }
}
