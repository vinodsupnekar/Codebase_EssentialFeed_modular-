//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Rjvi on 26/04/23.
//

import Foundation



public protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

public class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            isLoading: true,
            shouldRetry: false,
            image: nil
            ))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: image == nil,
            image: image))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
            view.display(FeedImageViewModel(
                description: model.description,
                location: model.location,
                isLoading: false,
                shouldRetry: true,
                image: nil))
        }
}
