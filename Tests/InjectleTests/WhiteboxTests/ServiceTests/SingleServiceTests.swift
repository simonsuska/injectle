// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import XCTest
import Mockaffee
@testable import Injectle

final class SingleServiceTests: XCTestCase {
    private var scopeMock: ScopeMock!
    private var singleService: SingleService!
    
    override func setUp() {
        self.scopeMock = ScopeMock(object: ServiceTestClass(value: 174))
        self.singleService = SingleService(scope: self.scopeMock)
        
        self.singleService.removeObject(forID: "20")
    }
    
    /// This test evaluates whether requesting an object works properly.
    func testRequestObject() {
        var service: ServiceTestClass?
            = self.singleService.requestObject(forID: "10") as? ServiceTestClass
        
        verify(on: self.scopeMock, called: exactly(1)).resolve()
        XCTAssertNotNil(service)
        
        service = self.singleService.requestObject(forID: "20") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(1)).resolve()
        XCTAssertNil(service)
        
        service = self.singleService.requestObject(forID: "30") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
        
        service = self.singleService.requestObject(forID: "10") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(3)).resolve()
        XCTAssertNotNil(service)
    }
}
