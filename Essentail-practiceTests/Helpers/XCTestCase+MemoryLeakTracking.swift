//
//  XCTestCase+MemoryLeakTracking.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/27.
//

import XCTest

extension XCTestCase {
    func trackFroMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line){
       addTeardownBlock { [weak instance] in
           XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
       }
    }
}
