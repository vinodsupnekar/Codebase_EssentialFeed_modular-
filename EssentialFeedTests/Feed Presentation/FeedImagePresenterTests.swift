//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Rjvi on 25/04/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOSPlatformFramework


struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let isLoading: Bool
    let shouldRetry: Bool
    let image: Image?

    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            isLoading: true,
            shouldRetry: false,
            image: nil
            ))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: image == nil,
            image: image))
    }
}

class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_dispalyLoadingImage() {
        
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation(with data: Data, for model: FeedImage) {
        let (sut, view) = makeSUT(imageTranfsormer: fail)
        let image = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation(with data: Data, for model: FeedImage) {
        let image = uniqueImage()
        let data = Data()
        let tranformedData = AnyImage()
        let (sut, view) = makeSUT(imageTranfsormer: { _ in tranformedData })
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, tranformedData)

    }
    
    // MARK:- Helper
    
    private func makeSUT(imageTranfsormer: @escaping (Data) -> AnyImage? = { _ in nil}, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTranfsormer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        return (sut, view)
    }

    private struct AnyImage: Equatable {}

    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
    
        func display(_ model: FeedImageViewModel<AnyImage>) {
                    messages.append(model)
                }
    
    }
}
