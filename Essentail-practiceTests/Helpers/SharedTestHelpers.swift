//
//  SharedTestHelpers.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/11/16.
//

import Foundation


func anyURL() -> URL {
    URL(string: "https://some-url")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
