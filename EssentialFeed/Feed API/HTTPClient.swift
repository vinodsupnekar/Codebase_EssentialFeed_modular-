//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Rjvi on 23/02/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
