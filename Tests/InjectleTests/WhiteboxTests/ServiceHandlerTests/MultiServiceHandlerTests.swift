import XCTest
import Mockaffee
@testable import Injectle

final class MultiServiceHandlerTests: XCTestCase {
    private var requestSM: ScopeMock!
    private var requestSH: MultiServiceHandler!
    
    private var unregisterSM: ScopeMock!
    private var unregisterSH: MultiServiceHandler!
    
    override func setUp() {
        // Setup for `testRequestService()`
        self.requestSM = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        self.requestSH = MultiServiceHandler(scope: self.requestSM)
        
        _ = self.requestSH.unregisterService(forID: "20")
        
        // Setup for `testUnregisterService()`
        self.unregisterSM = ScopeMock(object: ServiceHandlerTestClass(value: 203))
        self.unregisterSH = MultiServiceHandler(scope: self.unregisterSM)
        
        _ = self.unregisterSH.requestService(forID: "10")
        _ = self.unregisterSH.requestService(forID: "20")
        _ = self.unregisterSH.requestService(forID: "30")
    }
    
    /// This test evaluates whether requesting a service works properly.
    func testRequestService() {
        var service: ServiceHandlerTestClass?
            = self.requestSH.requestService(forID: "10") as? ServiceHandlerTestClass
        
        verify(on: self.requestSM, called: exactly(1)).resolve()
        XCTAssertNotNil(service)
        
        service = self.requestSH.requestService(forID: "20") as? ServiceHandlerTestClass
        verify(on: self.requestSM, called: exactly(1)).resolve()
        XCTAssertNil(service)
        
        service = self.requestSH.requestService(forID: "30") as? ServiceHandlerTestClass
        verify(on: self.requestSM, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
        
        service = self.requestSH.requestService(forID: "10") as? ServiceHandlerTestClass
        verify(on: self.requestSM, called: exactly(2)).resolve()
        XCTAssertNotNil(service)
    }
    
    /// This test evaluates whether unregistering a service works properly.
    func testUnregisterService() {
        var shouldUnregisterSH = self.unregisterSH.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterService(forID: "20")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterSH)
        
        shouldUnregisterSH = self.unregisterSH.unregisterService(forID: "30")
        XCTAssertFalse(shouldUnregisterSH)
    }
}
