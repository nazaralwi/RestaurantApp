//
//  XCTestCase+MemoryLeakTracking.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 25/11/21.
//

import XCTest

extension XCTestCase {
    public func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
