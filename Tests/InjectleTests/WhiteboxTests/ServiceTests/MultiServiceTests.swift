// Copyright (c) 2025 Simon Suska
// SPDX-License-Identifier: MIT

import XCTest
import Mockaffee
@testable import Injectle

final class MultiServiceTests: XCTestCase {
    private var scopeMock: ScopeMock!
    private var multiService: MultiService!
    
    override func setUp() {
        self.scopeMock = ScopeMock(object: ServiceTestClass(value: 174))
        self.multiService = MultiService(scope: self.scopeMock)
        
        self.multiService.removeObject(forID: "20")
    }
    
    /// This test evaluates whether requesting an object works properly.
    func testRequestObject() {
        var service: ServiceTestClass?
            = self.multiService.requestObject(forID: "10") as? ServiceTestClass
        
        verify(on: self.scopeMock, called: exactly(1)).resolve()
        XCTAssertNotNil(service)
        
        service = self.multiService.requestObject(forID: "20") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(1)).resolve()
        XCTAssertNil(service)
        
        service = self.multiService.requestObject(forID: "30") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
        
        service = self.multiService.requestObject(forID: "10") as? ServiceTestClass
        verify(on: self.scopeMock, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
    }
}
