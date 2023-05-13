//
//  FeedViewControllerTests+Localization.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/4/8.
//

import Foundation
import XCTest
import Essentail_practice

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
