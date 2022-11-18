//
//  FeedCacheTestHelpers.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/11/16.
//

import Foundation
import Essentail_practice


func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id,
                                           description: $0.description,
                                           location: $0.location,
                                           imageURL: $0.url)
    }
    return (models, local)

}

func uniqueImage() -> FeedImage{
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
    
    private var feedCacheMaxAgeInDays : Int {
        return 7
    }
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
