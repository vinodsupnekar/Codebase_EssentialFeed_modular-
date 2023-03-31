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
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
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
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
}
