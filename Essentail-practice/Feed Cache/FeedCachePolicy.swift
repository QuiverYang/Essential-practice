//
//  FeedCachePolicy.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/11/18.
//

import Foundation

final class FeedCachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDay : Int { return 7}
    
    static func validate(_ timestamp: Date, against date : Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDay, to: timestamp) else {return false}
        return date < maxCacheAge
    }
}
