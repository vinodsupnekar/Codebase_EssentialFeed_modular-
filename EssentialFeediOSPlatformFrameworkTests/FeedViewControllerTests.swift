//
//  FeedViewControllerTests.swift
//  EssentialFeediOSPlatformFrameworkTests
//
//  Created by Rjvi on 06/04/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOSPlatformFramework


final class FeedViewControllerTests: XCTestCase {
  
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadFeedCallCount, 1)
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndiacator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading  completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "a description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
    
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0])
        assertThat(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0])
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadImageURLs, [], "Expected no image URL requesr until view becomes visible")
        
        sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [image0.url], "Expected first image URL request once  view becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first image URL request once  view becomes visible")
        
        sut.simulateFeedImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image ")
        
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image ")

        loader.completeImageLoading(at: 0)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view while  first image loading completes successfully")
        
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change  for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once secong image loading completes with error")
        
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change  for second view once image loading completes with error")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image ")
        
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0,at: 0)
        
        XCTAssertEqual(view0?.renderedImage,imageData0, "Expected image for the first view once first image loading completes successfully")
        
        XCTAssertEqual(view1?.renderedImage,.none, "Expected no image state change for the second view once first image loading completes successfully")


        let imageData1 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData1,at: 1)
        
        XCTAssertEqual(view0?.renderedImage,imageData0, "Expected no image state change for the first view once first image loading completes successfully")
        
        XCTAssertEqual(view1?.renderedImage,imageData1, "Expected  image for the second view once first image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowRetryAction, false, "Expected no rerty action for first view while loading first image ")
        
        XCTAssertEqual(view1?.isShowRetryAction, false, "Expected no rerty action for second view while loading second image")

        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData,at: 0)
        
        XCTAssertEqual(view0?.isShowRetryAction, false, "Expected no retry action for the first view once first image loading completes successfully")
        
        XCTAssertEqual(view1?.isShowRetryAction,false, "Expected no retry action for the second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        
        XCTAssertEqual(view0?.isShowRetryAction,false, "Expected no retry action for the first view once first image loading completes successfully")
        
        XCTAssertEqual(view1?.isShowRetryAction,true, "Expected  retry action for the second view once first image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view = sut.simulateFeedImageVisible(at: 0)
        XCTAssertEqual(view?.isShowRetryAction, false, "Expected no rerty action while loading  image ")
        let invalidData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidData, at: 0)
        
        XCTAssertEqual(view?.isShowRetryAction, true, "Expected rerty action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryButton_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])
        
        let view0 = sut.simulateFeedImageVisible(at: 0)
        let view1 = sut.simulateFeedImageVisible(at: 1)

        XCTAssertEqual(loader.loadImageURLs, [image0.url, image1.url], "Expected two image URL requests for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)

        XCTAssertEqual(loader.loadImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action ")

        view0?.simulateRetryAction()
        
        XCTAssertEqual(loader.loadImageURLs, [image0.url, image1.url, image0.url], "Expected third image URL requests after first view retry action")
        
        view1?.simulateRetryAction()
        
        XCTAssertEqual(loader.loadImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected forth image URL requests after second view retry action")
        
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://any-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://any-url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])
        XCTAssertEqual(loader.loadImageURLs, [], "Expected no image URL requests until image is near visible")

        sut.simulateFeedImageNearVisible(at: 0)
        XCTAssertEqual(loader.loadImageURLs, [image0.url], "Expected  first image URL requests once fisrt image is near visible")

        sut.simulateFeedImageNearVisible(at: 1)
        XCTAssertEqual(loader.loadImageURLs, [image0.url, image1.url], "Expected second image URL requests once second image is near visible")

        
    }
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard  sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, but got \(sut.numberOfRenderedFeedImageViews()) instead")
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
            
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, but got \(String(describing: view)) instead")
        }
        let shouldLocationVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationVisible, "Expected isShowingLocation to be \(shouldLocationVisible) for image view at index \(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location)
        XCTAssertEqual(cell.locationText, image.location, "Expected location to be \(String(describing: image.location)) for image view at index \(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description to be \(String(describing: image.description)) for image view at index \(index))", file: file, line: line)

    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader{
        
        // MARK:- Feed Loader
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        private(set) var feedRequests: [((FeedLoader.Result) -> Void)] = []
        
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [],at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index:Int) {
            let error = NSError(domain: "", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK:- Image Loader
        private(set) var imageRequests =  [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping(FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError( at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageNotVisible(at row: Int){
        let view = simulateFeedImageVisible(at: row) as? FeedImageCell
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        let cell = dataSource?.tableView(self.tableView, cellForRowAt: index)
        cell?.startShimmering()
        return cell
    }
    
    private var feedImageSection: Int {
        return 0
    }
}

private extension FeedImageCell {

    func simulateRetryAction() {
        feedImageViewRetryButton.simulateTap()
    }
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowRetryAction: Bool {
        return !feedImageViewRetryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data?{
        return feedImageView.image?.pngData()
    }
    
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()
        return img!
    }
}
