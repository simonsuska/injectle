import XCTest
import Mockaffee
@testable import Injectle

final class MultiServiceHandlerTests: XCTestCase {
    // These properties are used for testing the unregister mechanism.
    private var scopeMock: ScopeMock!
    private var serviceHandler: MultiServiceHandler!
    
    override func setUp() {
        // Set up necessary stuff to be able to test the unregister mechanism.
        self.scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        self.serviceHandler = MultiServiceHandler(scope: self.scopeMock)
        
        // Request some services that can be unregistered afterwards.
        let _ = self.serviceHandler.requestService(forID: "10")
        let _ = self.serviceHandler.requestService(forID: "20")
        let _ = self.serviceHandler.requestService(forID: "30")
    }
    
    /// This test evaluates whether requesting a service works properly for a `MultiServiceHandler`.
    func testRequestService() {
        let scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        let serviceHandler = MultiServiceHandler(scope: scopeMock)
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "10") as? ServiceHandlerTestClass
        
        // Verify that a new object is resolved (and added to the `services` array).
        verify(on: scopeMock, called: exactly(1)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "20") as? ServiceHandlerTestClass
        
        // Verify that a new object is resolved (and added to the `services` array).
        verify(on: scopeMock, called: exactly(2)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "10") as? ServiceHandlerTestClass
        
        // Verify that no new object is resolved but the one stored in the `services`
        // array is reused.
        verify(on: scopeMock, called: exactly(2)).resolve()
        
        var _: ServiceHandlerTestClass?
            = serviceHandler.requestService(forID: "30") as? ServiceHandlerTestClass
        
        // Verify that a new object is resolved (and added to the `services` array).
        verify(on: scopeMock, called: exactly(3)).resolve()
    }
    
    /// This test evaluates whether unregistering a service works properly for
    /// a `MultiServiceHandler` without requesting any service before.
    func testUnregisterServiceInitial() {
        let scopeMock = ScopeMock(object: ServiceHandlerTestClass(value: 174))
        let serviceHandler = MultiServiceHandler(scope: scopeMock)
        
        let shouldUnregisterServiceHandler = serviceHandler.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterServiceHandler)
    }
    
    /// This test evaluates whether unregistering a service works properly for a `MultiServiceHandler`.
    func testUnregisterService() {
        var shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "20")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "10")
        XCTAssertFalse(shouldUnregisterServiceHandler)
        
        shouldUnregisterServiceHandler = self.serviceHandler.unregisterService(forID: "30")
        XCTAssertFalse(shouldUnregisterServiceHandler)
    }
}
