//
//  XCTestCase+FeedStoreSpec.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 30/03/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieve_deleiversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .emtpy)
    }

    func assertThatRetrieve_hasNoSideEffectsOnEmptyache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .emtpy)
        expect(sut, toRetrieve: .emtpy)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date) ,to sut: FeedStore) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(cache.feed, timeStamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "wait for cache deletion")
        sut.deleteCacheFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.emtpy, .emtpy),
                 (.failure, .failure):
                break
                
            case let (.found(expectedResult), .found(retrieved)):
                XCTAssertEqual(expectedResult.feed, retrieved.feed, file: file, line: line)
                XCTAssertEqual(expectedResult.timestamp, retrieved.timestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
