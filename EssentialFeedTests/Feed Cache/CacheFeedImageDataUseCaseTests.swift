//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 08/05/23.
//

import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
            let (_, store) = makeSUT()

            XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataForURL_requestImageDataInsertionForURL() {
        let (sut, store)  = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store)  = makeSUT()
        
        let expectedResult: LocalFeedImageDataLoader.SaveResult = .failure(LocalFeedImageDataLoader.SaveError.failed)
        
        let exp = expectation(description: "Wait for load completion")

        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                  .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError)
            default :
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")

        }
        exp.fulfill()
        }
        
        let insertionError = anyNSError()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)

    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(store,file: file, line: line)
        trackForMemoryLeaks(sut,file: file, line: line)
        return (sut, store)
    }

}
