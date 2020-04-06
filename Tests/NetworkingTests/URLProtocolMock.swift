//
//  URLProtocolMock.swift
//  NetworkingTests
//
//  Created by Asad Rana on 2/29/20.
//  Copyright © 2020 anrana. All rights reserved.
//

import Foundation

enum URLProtocolMockAction {
    case response(data: Data, response: URLResponse)
    case error(error: Error)
    case noResponse
}

@objc class URLProtocolMock: URLProtocol {
    static var action: URLProtocolMockAction!

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        defer {
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        switch URLProtocolMock.action {
        case .error(let error):
            self.client?.urlProtocol(self, didFailWithError: error)
        case .response(let data, let response):
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        case .noResponse:
            self.client?.urlProtocol(self, didLoad: Data())
            self.client?.urlProtocol(self, didReceive: URLResponse.init(), cacheStoragePolicy: .notAllowed)
        case .none:
            return 
        }
    }

    override func stopLoading() {

    }
}
