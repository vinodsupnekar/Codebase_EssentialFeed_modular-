//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 31/03/23.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deleiversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieve_deleiversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyache() {
        let sut = makeSUT()
        
        assertThatRetrieve_hasNoSideEffectsOnEmptyache(on: sut)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)

    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPrevioslyInsertedData() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK:- Helpers
    
    private func makeSUT( storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBudndle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL,bundle: storeBudndle)
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
}
