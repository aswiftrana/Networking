//
//  URLSessionMock.swift
//  NetworkingTests
//
//  Created by Asad Rana on 2/29/20.
//  Copyright © 2020 anrana. All rights reserved.
//

import Foundation

extension URLSession {
    static func makeMock() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }
}
