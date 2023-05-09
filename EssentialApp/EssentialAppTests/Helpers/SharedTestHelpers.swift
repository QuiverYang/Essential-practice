//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import Foundation
import Essentail_practice

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "some-url")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "", location: "", url: anyURL())]
}
