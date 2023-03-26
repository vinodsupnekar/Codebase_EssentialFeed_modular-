//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 26/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(_ completion: @escaping FeedStore.RetrievalCompletion ) {
        completion(.emtpy)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deleiversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .emtpy:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
