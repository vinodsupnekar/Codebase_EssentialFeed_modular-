//
//  XCTestCase+MemoryLeaksTracker.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 01/03/23.
//

import XCTest

extension XCTestCase {
     func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line :UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated.Potential memory leak",file: file, line: line)
        }
    }
}
