//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 17/03/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return  Data("any data".utf8)
}
