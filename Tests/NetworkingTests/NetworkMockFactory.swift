//
//  NetworkMockFactory.swift
//  NetworkingTests
//
//  Created by Asad Rana on 2/29/20.
//  Copyright © 2020 anrana. All rights reserved.
//

import Foundation
@testable import Networking

private let genericURL = URL.init(string: "http://www.foo.com")!

enum NetworkMockFactory {
    enum Response {
        static let valid = HTTPURLResponse.init(url: genericURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        static let invalid403 = HTTPURLResponse.init(url: genericURL, statusCode: 403, httpVersion: nil, headerFields: nil)!
    }
    
    enum Error {
        static let networkConnectionLost = URLError.init(.networkConnectionLost)
    }
    
    enum ClientError {
        static let networkConnectionLost = Networking.ClientError.network(code: -1005, reason:"The operation couldn’t be completed. (NSURLErrorDomain error -1005.)")
    }
    
    enum Model {
        static func data<T: Encodable>(for obj: T) -> Data {
            return try! JSONEncoder().encode(obj)
        }
    }
    
    enum Components {
        static let valid: URLComponents = {
            var components = URLComponents.init()
            components.scheme = "https"
            components.host = "www.google.com"
            return components
        }()
        
        static let invalid: URLComponents = {
            var components = URLComponents.init()
            components.scheme = "https"
            components.host = "www.google.com"
            components.path = "foo"
            return components
        }()
    }
}
